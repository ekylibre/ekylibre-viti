module Sage
  module ISeven
    class JournalEntriesExchanger < ActiveExchanger::Base
      def check
        # Imports journal entries into journal to make accountancy in XML format from Sage
        # filename example : export_comptabilité_TREETE SAS_2018.ecx
        # Squeleton are:
        #  <ECX>
        ## <INFORMATION> 1 occurence
        ## <DOSSIER> 1 occurence
        ## <PC> 1 occurence
        ### <COMPTE CATEGORIEAV="" COMPTE="101000000" NOM="Capital" OPTIONS="0" SOLDE="-353000" TAUXTVA=" 0" UNITE=""/>
        ### <COMPTE ...
        ## <JOURNAL> n occurences
        ### <PIECE COURSDEVISE="1" DATEECR="2018-01-12" DEVISE="E" DGIORIGINE="0" ETAT="0" INFOORIGINE="" LIBPIECE="Vente eau-de-vie - Cognac Chollet (001)" TYPEORIGINE="">
        #### <LIGNE CARLETTRAGE="" COMPTE="411008178" DATEECR="2018-01-18" LIBMANU="Vente eau-de-vie - Croizet (sas)" MONTANT=" 0" MONTANTREF=" 5158.22" QUANTITE=" 0" REFERENCE="002" SENS="1" TAUXTVA=" 0" UNITE=""/>
        #### <LIGNE ...
        ### <PIECE...
        #### <LIGNE ...
        ## <JOURNAL>..

        now = Time.zone.now
        valid = true

        # check encoding
        source = File.read(file)
        detection = CharlockHolmes::EncodingDetector.detect(source)
        puts detection[:encoding].inspect.red
        if detection[:encoding] != "ISO-8859-1" && detection[:encoding] != "UTF-8"
          valid = false
        end
        # check if file is a valid XML
        f = File.open(file)
        # f = sanitize(f)
        doc = Nokogiri::XML(f, &:noblanks)
        valid
      end

      def import
        byebug

        doc = Nokogiri::XML(File.open(file)) do |config|
          config.strict.nonet.noblanks
        end

        period_started_on = doc.at_css('INFORMATION').attribute('PERIODEDEBUTN').value
        period_stopped_on = doc.at_css('INFORMATION').attribute('PERIODEFINN').value
        fy = FinancialYear.where("stopped_on = ?", period_stopped_on.to_date)
        if fy.any?
          fy = fy.first
        else
          w.info "Creating Financial Year"
          fy = FinancialYear.create!(started_on: period_started_on.to_date, stopped_on: period_stopped_on.to_date)
        end

        # journal = Journal.find_or_create_by(code: 'SAGE', nature: 'various', name: 'Import SAGE i7')

        # build editor sender data
        data_exported_on = doc.at_css('INFORMATION').attribute('DATECREATION').value.to_date
        version_information = doc.at_css('INFORMATION').attribute('VERSIONECX').value + ' - ' + doc.at_css('INFORMATION').attribute('VERSIONEMETTEUR').value

        editor_data_providers = {sender_name: 'sage_i7', created_on: data_exported_on, sender_infos: version_information }

        find_or_creat_account(doc, period_started_on)

        # find or create entries
        w.reset!(doc.css('PIECE').count)
        entries = {}

        find_or_create_entries(doc, fy, editor_data_providers, entries)

        w.reset!(entries.keys.size)
        entries.values.each do |entry|
          w.info "JE : #{entry}".inspect.yellow
          j = JournalEntry.create!(entry)
          w.info "JE created: #{j.number} | #{j.printed_on}".inspect.yellow
          w.check_point
        end

      end

      def find_or_creat_account(doc, period_started_on)
        # create or update account chart with data in file
        # check account lenght
        # find or create account
        pc = doc.at_css('PC')
        w.count = pc.css('COMPTE').count
        acc_number_length = pc.css('COMPTE').first.attribute('COMPTE').value.length

        if Preference[:account_number_digits] != acc_number_length
          Preference.set!(:account_number_digits, acc_number_length)
          #TODO check if current account are ready
        end

        pc.css('COMPTE').each do |account|
          acc_number = account.attribute('COMPTE').value
          acc_name = account.attribute('NOM').value
          # Exclude number with radical class only like 7000000 or 40000000
          next if acc_number.strip.gsub(/0+\z/, '').in?(['1','2','3','4','5','6','7','8'])


          account = find_or_creat_account_by_number(acc_number, acc_name)
          # # find account by number
          # acc = Account.find_or_initialize_by(number: acc_number)
          # attributes = {name: acc_name}
          # # add attributes if 401 / 411
          # if acc_number.start_with?('401', '411')
          #   w.info "Create auxiliary account and entities"
          #   attributes[:centralizing_account_name] = acc_number.start_with?('401') ? 'suppliers' : 'clients'
          #   attributes[:nature] = 'auxiliary'
          #   aux_number = acc_number[3, acc_number.length]
          #   if aux_number.match(/\A0*\z/).present?
          #     w.info "We can't import auxiliary number #{aux_number} with only 0. Mass change number in your file before importing"
          #     attributes[:auxiliary_number] = '00000A'
          #   else
          #     attributes[:auxiliary_number] = aux_number
          #   end
          # end
          # acc.attributes = attributes
          # w.info "account attributes ! : #{attributes.inspect.red}"
          # acc.save!
          # w.info "account saved ! : #{acc.label.inspect.red}"



          entity_evolved(acc_number, acc_name, period_started_on, account) if acc_number.start_with?('401', '411')
          # Adds a real entity with known information if account number like 401 or 411


          w.check_point
        end
      end


      def find_or_creat_account_by_number(acc_number, acc_name)
        # find account by number
          acc = Account.find_or_initialize_by(number: acc_number)
          attributes = {name: acc_name}
          # add attributes if 401 / 411
          if acc_number.start_with?('401', '411')
            w.info "Create auxiliary account and entities"
            attributes[:centralizing_account_name] = acc_number.start_with?('401') ? 'suppliers' : 'clients'
            attributes[:nature] = 'auxiliary'
            aux_number = acc_number[3, acc_number.length]
            if aux_number.match(/\A0*\z/).present?
              w.info "We can't import auxiliary number #{aux_number} with only 0. Mass change number in your file before importing"
              attributes[:auxiliary_number] = '00000A'
            else
              attributes[:auxiliary_number] = aux_number
            end
          end
          acc.attributes = attributes
          w.info "account attributes ! : #{attributes.inspect.red}"
          acc.save!
          w.info "account saved ! : #{acc.label.inspect.red}"
      end

      def entity_evolved(acc_number, acc_name, period_started_on, acc)
        last_name = acc_name.mb_chars.capitalize
        modified = false
        entity = Entity.where('last_name ILIKE ?', last_name).first
        entity ||= Entity.create!(last_name: last_name, nature: 'organization', first_met_at: period_started_on.to_date)
        if entity.first_met_at && period_started_on.to_date && period_started_on.to_date < entity.first_met_at
          entity.first_met_at = period_started_on.to_date
          modified = true
        end
        if acc_number.start_with?('401')
          entity.supplier = true
          entity.supplier_account_id = acc.id
          modified = true
        end
        if acc_number.start_with?('411')
          entity.client = true
          entity.client_account_id = acc.id
          modified = true
        end
        entity.save if modified
        w.info "entity save ! : #{entity.full_name.inspect.red}" if modified
      end

      def find_or_create_entries(doc, fy, editor_data_providers, entries)
        # transcoding journal
        default_journal_natures = {
          'A' => :purchases,
          'V' => :sales,
          'T' => :bank,
          'D' => :various
        }

        #useless => can directly find_or_create_by?
        unless default_result_journal = Journal.find_by(nature: 'result')
          default_result_journal = Journal.find_or_create_by(code: 'RESU', nature: 'result', name: 'Résultat')
        end

        doc.css('JOURNAL').each do |sage_journal|
          # get attributes in file ## <JOURNAL> n occurences
          jou_code = sage_journal.attribute('CODE').value
          jou_name = sage_journal.attribute('NOM').value
          jou_nature = sage_journal.attribute('TYPEJOURNAL').value

          #useless => can directly find_or_create_by?
          unless journal = Journal.find_by(name: jou_name)
            journal = Journal.find_or_create_by(code: jou_code, nature: default_journal_natures[jou_nature], name: jou_name)
          end
          # if cashe account journal, create cashe
          if jou_nature == 'T'
            jou_account = sage_journal.attribute('CMPTASSOCIE').value
            jou_iban = sage_journal.attribute('IBANPAPIER').value.delete(' ')
            cash_attributes = { name: "enumerize.cash.nature.bank_account".t,
                                nature: 'bank_account',
                                main_account: Account.find_or_create_by_number(jou_account),
                                journal: journal }

            if !jou_iban.blank? && jou_iban.start_with?('IBAN')
              cash_attributes.merge!(iban: jou_iban[4..30])
            end
            cash = Cash.find_or_create_by(cash_attributes)
          end

          sage_journal.css('PIECE').each_with_index do |sage_journal_entry, index|
            printed_on = sage_journal_entry.attribute('DATEECR').value.to_date
            state = sage_journal_entry.attribute('ETAT').value
            line_number = index + 1
            number = jou_code + '_' + printed_on.to_s + '_' + line_number.to_s
            w.info "--------------------number : #{number}--------------------------".inspect.yellow
            # change journal in case of result journal entry (31/12/AAAA and ETAT = 8)
            if printed_on.day == fy.stopped_on.day && printed_on.month == fy.stopped_on.month && state == '8'
              c_journal = default_result_journal
            else
              c_journal = journal
            end

            unless entries[number]
              entries[number] = {
                printed_on: printed_on,
                journal: c_journal,
                number: line_number,
                currency: journal.currency,
                providers: editor_data_providers,
                items_attributes: {}
              }
            end

            sage_journal_entry.css('LIGNE').each do |sage_journal_entry_item|
              sjei_acc_number = sage_journal_entry_item.attribute('COMPTE').value
              sjei_account = Account.find_by_number(sjei_acc_number)
              unless sjei_account
                if sjei_acc_number.start_with?('401', '411')
                  centralizing_account_name = sjei_acc_number.start_with?('401') ? 'suppliers' : 'clients'
                  nature = 'auxiliary'
                  radical = sjei_acc_number[0, 3]
                  aux_number = sjei_acc_number[3, sjei_acc_number.length]
                  if aux_number.match(/\A0*\z/).present?
                    w.info "We can't import auxiliary number #{sjei_acc_number} with only 0. Mass change number in your file before importing"
                    aux_number = '00000A'
                  end
                  sjei_acc_number = radical + aux_number
                end
                sjei_account = Account.find_by_number(sjei_acc_number)
                unless sjei_account
                  sjei_account = Account.create!(number: sjei_acc_number,
                                              nature: nature,
                                              centralizing_account_name: centralizing_account_name,
                                              auxiliary_number: aux_number)
                end
              end

              if sjei_account
                w.info "account found in line! : #{sjei_account.number.inspect.yellow}"
              else
                w.warn "account not found in line for number : #{sjei_acc_number.inspect.red}"
              end

              sjei_label = sage_journal_entry_item.attribute('LIBMANU').value
              sjei_amount = sage_journal_entry_item.attribute('MONTANTREF').value
              sjei_direction = sage_journal_entry_item.attribute('SENS').value #1 = D / -1 = C

              id = (entries[number][:items_attributes].keys.max || 0) + 1
              entries[number][:items_attributes][id] = {
                real_debit: (sjei_direction == '1' ? sjei_amount.to_f : 0.0),
                real_credit: (sjei_direction == '-1' ? sjei_amount.to_f : 0.0),
                account: sjei_account,
                name: sjei_label
              }
            end
            w.check_point
          end
        end
      end

    end
  end
end
