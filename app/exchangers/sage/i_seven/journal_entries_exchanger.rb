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
        def self.read_from(doc, **options)
          period_started_on = doc.at_css('INFORMATION').attribute('PERIODEDEBUTN').value
          period_stopped_on = doc.at_css('INFORMATION').attribute('PERIODEFINN').value
          data_exported_on = doc.at_css('INFORMATION').attribute('DATECREATION').value
          version_information = doc.at_css('INFORMATION').attribute('VERSIONECX').value + ' - ' + doc.at_css('INFORMATION').attribute('VERSIONEMETTEUR').value

          new(period_started_on, period_stopped_on, data_exported_on, version_information, doc, options)
        end

        def self.load_from(file, **options)
          source = File.read(file)
          detection = CharlockHolmes::EncodingDetector.detect(source)

          doc = Nokogiri.XML(source, nil, detection[:encoding], &:noblanks)
          SageFileInformation.read_from(doc, options)
        end

        attr_reader :period_started_on, :period_stopped_on, :data_exported_on, :version_information, :editor_data_providers, :doc

        def initialize(period_started_on, period_stopped_on, data_exported_on, version_information, doc, **options)
          @period_started_on = period_started_on.to_date
          @period_stopped_on = period_stopped_on.to_date
          @data_exported_on = data_exported_on.to_date
          @version_information = version_information
          # TODO: normaliser le contenu de provider (specifier les champs)
          @editor_data_providers = { sender_name: 'sage_i7', import_id: options[:import_id], sender_infos: version_information }
          @doc = doc
        end
      end

      def check
        valid = true
        if financial_year.nil?
          valid = false
          w.error "The financial year is needed for #{file_info.period_stopped_on}"
        end
        valid
      end

      def import
        accounts = accounts_retrieval(file_info.doc)
        entity_accounts = accounts.select { |number, _account| number.start_with?(client_account_radix, supplier_account_radix) }

        entity_accounts.each do |_key, entity_account|
          update_entity(file_info.period_started_on, entity_account)
        end

        entries = entries_items(file_info.doc, financial_year, file_info.editor_data_providers)
        entries.each do |_key, entry|
          JournalEntry.create!(entry)
        end
      end

      private

      def file_info
        @file_info ||= SageFileInformation.load_from(file, options)
      end

      def financial_year
        @financial_year ||= FinancialYear.find_by('stopped_on = ?', file_info.period_stopped_on)
      end

      def client_account_radix
        @client_account_radix ||= Preference.value(:client_account_radix).presence || '411'
      end

      def supplier_account_radix
        @supplier_account_radix ||= Preference.value(:supplier_account_radix).presence || '401'
      end

      # create or update account chart with data in file
      def accounts_retrieval(doc)
        accounts = {}
        # check account length
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
          next if acc_number.strip.gsub(/0+\z/, '').in?(%w[1 2 3 4 5 6 7 8])

          accounts[acc_number] = find_or_create_account_by_number(acc_number, acc_name)
        end

        accounts
      end

      def find_or_create_account_by_number(acc_number, acc_name)
        acc = Account.find_or_initialize_by(number: acc_number)
        attributes = { name: acc_name }
        if acc_number.start_with?(client_account_radix, supplier_account_radix)
          attributes[:centralizing_account_name] = acc_number.start_with?(client_account_radix) ? 'suppliers' : 'clients'
          attributes[:nature] = 'auxiliary'
          aux_number = acc_number[client_account_radix.length, acc_number.length]

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

        entity = Entity.where('supplier_account_id = ? or client_account_id = ?', acc.id, acc.id).first

        entity ||= Entity.create!(last_name: last_name, nature: 'organization', first_met_at: period_started_on)
        if entity.first_met_at && period_started_on && period_started_on < entity.first_met_at
          entity.first_met_at = period_started_on
        end
        if acc.number.start_with?(client_account_radix)
          entity.supplier = true
          entity.supplier_account_id = acc.id
        else
          entity.client = true
          entity.client_account_id = acc.id
        end

        entity.save
      end

      def is_bank?(sage_nature)
        sage_nature === 'T'
      end

      def is_closing_entry?(printed_on, stopped_on, state)
        printed_on.day == stopped_on.day && printed_on.month == stopped_on.month && state == '8'
      end

      def is_forward_entry?(printed_on, started_on, state)
        printed_on.day == started_on.day && printed_on.month == started_on.month && state == '8'
      end

      def entries_items(doc, fy, editor_data_providers)
        entries = {}

        doc.css('JOURNAL').each do |sage_journal|
          # get attributes in file ## <JOURNAL> n occurences
          jou_code = sage_journal.attribute('CODE').value
          jou_name = sage_journal.attribute('NOM').value
          jou_nature = sage_journal.attribute('TYPEJOURNAL').value

          journal = find_or_create_journal(jou_code, jou_name, jou_nature)

          create_cash(sage_journal, journal) if is_bank?(jou_nature)

          sage_journal.css('PIECE').each_with_index do |sage_journal_entry, index|
            printed_on = sage_journal_entry.attribute('DATEECR').value.to_date
            state = sage_journal_entry.attribute('ETAT').value
            line_number = index + 1
            number = jou_code + '_' + printed_on.to_s + '_' + line_number.to_s
            # change journal in case of result journal entry (31/12/AAAA and ETAT = 8)
            # Sate == 8 ==> Ecriture de generation de résultat si générées à la date de cloture
            c_journal = if  is_closing_entry?(printed_on, fy.stopped_on, state)
                          Journal.find_or_create_default_result_journal
                        elsif is_forward_entry?(printed_on, fy.started_on, state)
                          Journal.find_or_create_default_forward_journal
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
              sjei_account = create_account_by(sage_journal_entry_item)

              sjei_label = sage_journal_entry_item.attribute('LIBMANU').value
              sjei_amount = sage_journal_entry_item.attribute('MONTANTREF').value
              sjei_direction = sage_journal_entry_item.attribute('SENS').value # 1 = D / -1 = C

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
        main_account =  Account.find_or_create_by_number(jou_account)
        cash_attributes = { name: 'enumerize.cash.nature.bank_account'.t,
                            nature: 'bank_account',
                            journal: journal }

        if jou_iban.present? && jou_iban.start_with?('IBAN')
          cash_attributes.merge!(iban: jou_iban[4..-1])
        end
        Cash.create_with(cash_attributes).find_or_create_by(main_account: main_account)
      end

      def find_or_create_journal(jou_code, jou_name, jou_nature)
        Journal.create_with(code: jou_code, nature: DEFAULT_JOURNAL_NATURES[jou_nature])
               .find_or_create_by(name: jou_name)
      end

      def create_account_by(sage_journal_entry_item)
        sjei_acc_number = sage_journal_entry_item.attribute('COMPTE').value
        Account.find_or_create_by_number(sjei_acc_number)
      end
    end
  end
end
