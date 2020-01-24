module Sage
  module ISeven
    class JournalEntriesExchanger < ActiveExchanger::Base
      DEFAULT_JOURNAL_NATURES = {
          'A' => :purchases,
          'V' => :sales,
          'T' => :bank,
          'D' => :various
        }.freeze

      class SageFileInformation

        def self.read_from(doc)
          period_started_on = doc.at_css('INFORMATION').attribute('PERIODEDEBUTN').value
          period_stopped_on = doc.at_css('INFORMATION').attribute('PERIODEFINN').value
          data_exported_on = doc.at_css('INFORMATION').attribute('DATECREATION').value
          version_information = doc.at_css('INFORMATION').attribute('VERSIONECX').value + ' - ' + doc.at_css('INFORMATION').attribute('VERSIONEMETTEUR').value

          new(period_started_on, period_stopped_on, data_exported_on, version_information, doc)
        end
        def self.load_from(f)
          source = File.read(f)
          detection = CharlockHolmes::EncodingDetector.detect(source)

          doc = Nokogiri.XML(source, nil, detection[:encoding], &:noblanks)
          SageFileInformation.read_from(doc)
        end

        attr_reader :period_started_on, :period_stopped_on, :data_exported_on, :version_information, :editor_data_providers, :doc

        def initialize(period_started_on, period_stopped_on, data_exported_on, version_information, doc)
          @period_started_on = period_started_on.to_date
          @period_stopped_on = period_stopped_on.to_date
          @data_exported_on = data_exported_on.to_date
          @version_information = version_information
          @editor_data_providers = {sender_name: 'sage_i7', created_on: data_exported_on, sender_infos: version_information }
          @doc = doc
        end

      end

      def check
        valid = true
        file_info = SageFileInformation.load_from(file)

        fy = FinancialYear.find_by("stopped_on = ?", file_info.period_stopped_on)

        if fy.nil?
          valid = false
          w.error "The financial year is needed for #{file_info.period_stopped_on}"
        end
        valid
      end

      def import
        file_info = SageFileInformation.load_from(file)

        accounts = accounts_retrieval(file_info.doc)
        entity_accounts = accounts.select { |number, _account| number.start_with?("401", "411") }

        entity_accounts.each do |_key, entity_account|
          update_entity(file_info.period_started_on, entity_account)
        end

        fy = FinancialYear.find_by("stopped_on = ?", file_info.period_stopped_on)

        entries = entries_items(file_info.doc, fy, file_info.editor_data_providers)
        entries.each do |key, entry|
          j = JournalEntry.create!(entry)
        end

      end

      # create or update account chart with data in file
      def accounts_retrieval(doc)
        accounts = {}
        # check account lenght
        # find or create account
        pc = doc.at_css('PC')
        acc_number_length = pc.css('COMPTE').first.attribute('COMPTE').value.length

        if Preference[:account_number_digits] != acc_number_length
          raise StandardError.new("The account number length cant't be different from your own settings")
        end

        pc.css('COMPTE').each do |account|
          acc_number = account.attribute('COMPTE').value
          acc_name = account.attribute('NOM').value
          # Exclude number with radical class only like 7000000 or 40000000
          next if acc_number.strip.gsub(/0+\z/, '').in?(['1','2','3','4','5','6','7','8'])

          accounts[acc_number] = find_or_create_account_by_number(acc_number, acc_name)
        end

        accounts
      end

      def find_or_create_account_by_number(acc_number, acc_name)
        acc = Account.find_or_initialize_by(number: acc_number)
        attributes = {name: acc_name}
        if acc_number.start_with?('401', '411')
          attributes[:centralizing_account_name] = acc_number.start_with?('401') ? 'suppliers' : 'clients'
          attributes[:nature] = 'auxiliary'
          aux_number = acc_number[3, acc_number.length]
          if aux_number.match(/\A0*\z/).present?
            raise StandardError.new("Can't create account. Number provided can't be a radical class")
          else
            attributes[:auxiliary_number] = aux_number
          end
        end
        acc.attributes = attributes
        acc.save!
        acc
      end

      def update_entity(period_started_on, acc)
        last_name = acc.name.mb_chars.capitalize
        modified = false
        # FIXME: Pas possible quid des homonymes
        entity = Entity.where('last_name ILIKE ?', last_name).first
        # FIXME: pourquoi orga par default?
        # FIXME: pourquoi period_started_on ?
        entity ||= Entity.create!(last_name: last_name, nature: 'organization', first_met_at: period_started_on)
        if entity.first_met_at && period_started_on && period_started_on < entity.first_met_at
          # FIXME why?
          entity.first_met_at = period_started_on
          modified = true
        end
        if acc.number.start_with?('401')
          entity.supplier = true
          entity.supplier_account_id = acc.id
          modified = true
        else
          entity.client = true
          entity.client_account_id = acc.id
          modified = true
        end

        entity.save if modified
      end

      def entries_items(doc, fy, editor_data_providers)
        entries = {}

        default_result_journal = find_or_create_default_result_journal

        doc.css('JOURNAL').each do |sage_journal|
          # get attributes in file ## <JOURNAL> n occurences
          jou_code = sage_journal.attribute('CODE').value
          jou_name = sage_journal.attribute('NOM').value
          jou_nature = sage_journal.attribute('TYPEJOURNAL').value

          journal = find_or_create_journal(jou_code, jou_name, jou_nature)

          create_cash(sage_journal, journal) if jou_nature == 'T'

          sage_journal.css('PIECE').each_with_index do |sage_journal_entry, index|
            printed_on = sage_journal_entry.attribute('DATEECR').value.to_date
            state = sage_journal_entry.attribute('ETAT').value
            line_number = index + 1
            number = jou_code + '_' + printed_on.to_s + '_' + line_number.to_s
            # change journal in case of result journal entry (31/12/AAAA and ETAT = 8)
            c_journal = if printed_on.day == fy.stopped_on.day && printed_on.month == fy.stopped_on.month && state == '8'
              default_result_journal
            else
              journal
            end

            entries[number] = {
              printed_on: printed_on,
              journal: c_journal,
              number: line_number,
              currency: journal.currency,
              providers: editor_data_providers,
              items_attributes: []
            }

            sage_journal_entry.css('LIGNE').each do |sage_journal_entry_item|

              sjei_account = sage_journal_entry_item_account_creation(sage_journal_entry_item)

              sjei_label = sage_journal_entry_item.attribute('LIBMANU').value
              sjei_amount = sage_journal_entry_item.attribute('MONTANTREF').value
              sjei_direction = sage_journal_entry_item.attribute('SENS').value #1 = D / -1 = C

              entries[number][:items_attributes] << {
                real_debit: (sjei_direction == '1' ? sjei_amount.to_f : 0.0),
                real_credit: (sjei_direction == '-1' ? sjei_amount.to_f : 0.0),
                account: sjei_account,
                name: sjei_label
              }
            end
          end
        end
        entries
      end

      def create_cash(sage_journal, journal)
        jou_account = sage_journal.attribute('CMPTASSOCIE').value
        jou_iban = sage_journal.attribute('IBANPAPIER').value.delete(' ')
        cash_attributes = { name: "enumerize.cash.nature.bank_account".t,
                            nature: 'bank_account',
                            main_account: Account.find_or_create_by_number(jou_account),
                            journal: journal }

        if !jou_iban.blank? && jou_iban.start_with?('IBAN')
          # Style: iban always have 30 chars?
          cash_attributes.merge!(iban: jou_iban[4..30])
        end
        # FIXME: not good. Use create_with or sth like this
        cash = Cash.find_or_create_by(cash_attributes)
      end

      def find_or_create_journal(jou_code, jou_name, jou_nature)
        journal = Journal.create_with(code: jou_code, nature: DEFAULT_JOURNAL_NATURES[jou_nature])
                         .find_or_create_by(name: jou_name)
      end

      def sage_journal_entry_item_account_creation(sage_journal_entry_item)
        sjei_acc_number = sage_journal_entry_item.attribute('COMPTE').value
        sjei_account = Account.find_or_create_by_number(sjei_acc_number)
        sjei_account
      end

      private

        def find_or_create_default_result_journal
          unless default_result_journal = Journal.create_with(code: 'RESU', name: 'Résultat')
            default_result_journal = Journal.find_or_create_by(nature: 'result')
          end
        end

    end
  end
end
