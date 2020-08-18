module Duke
  class HarvestReceptions < Duke::DukeParsing

    def handle_parse_sentence(params)
      Ekylibre::Tenant.switch params['tenant'] do
        targets = []
        species = []
        destination = []
        # Finding when it happened and how long it lasted, + getting cleaned user_input
        duration, user_input = extract_duration_fr(params[:user_input].downcase)
        intervention_date, user_input = extract_date_fr(user_input)
        user_input, parameters = extract_reception_parameters(user_input)
        # Create all combos of 1 to 4 words from the inputs , with their indexes, to use for matching
        user_inputs_combos = self.create_words_combo(user_input)
        # Iterate through all user's combo of words (with their indexes)
        user_inputs_combos.each do |index, combo|
          # Define minimum matching level, initialize saved_hash and recognized list to None
          level = 0.90
          saved_hash = nil
          list = nil
          # Iterating through varieties
          Plant.availables(at: intervention_date).each do |pl|
            level, saved_hash, list = compare_elements(combo, pl['specie_variety']['specie_variety_name'], index, level, pl['specie_variety']['specie_variety_name'], species, saved_hash, list)
            level, saved_hash, list = compare_elements(combo, pl[:name], index, level, pl[:id], targets, saved_hash, list)
          end
          Equipment.availables(at: intervention_date).where("variety='tank'").each do |tank|
            level, saved_hash, list = compare_elements(combo, tank[:name], index, level, tank[:id], destination, saved_hash, list)
          end
          # If we recognized something, we append it to the correct list and we remove what matched from the user_input
          unless saved_hash.nil?
            list = add_to_recognize_final(saved_hash, list, [targets, species, destination])
          end
        end
        targets = extract_plant_area(user_input, targets)
        parsed = {:targets => targets,
                  :species => species,
                  :destination => destination,
                  :parameters => parameters,
                  :duration => duration,
                  :intervention_date => intervention_date,
                  :user_input => params[:user_input]}
        # Find if crucials parameters haven't been given, to ask again to the user
        what_next, sentence, optional = find_missing_parameters(parsed)
        return  { :parsed => parsed, :asking_again => what_next, :sentence => sentence, :optional => optional}
      end
    end

    def handle_parse_parameter(params)
      parsed = params[:parsed]
      parameter = params[:parameter]
      value = params[parameter]
      # Value is a number value returned by watson as a parameter
      if value.nil?
        # If we don't have a value, we search for an integer/float inside the user input
        hasNumbers = params[:user_input].match('\d{1,4}((\.|,)\d{1,2})?')
        if hasNumbers
          value = hasNumbers[0].gsub(',','.').gsub(' ','')
        else
          # If we couldn't find one, we cancel the functionnality
          return {:asking_again => "cancel"}
        end
      # If we have a value, we should check if watson didn't return an integer instead of a float
      elsif params[:user_input].match(/#{value}(\.\d{1,2})/)
        new_value_matches = params[:user_input].match(/#{value}(\.\d{1,2})/)
        value = new_value_matches[0]
      end
      # If we are parsing a quantity, we search for an unit inside the user input
      if parameter == "quantity"
        if params[:user_input].match('(?i)(kg|kilo)')
          unit = 'kg'
        elsif params[:user_input].match('(?i)\d *t\b|tonne')
          unit = 'tonne'
        else
          unit = 'hl'
        end
        parsed[:parameters][parameter] = {:rate => value.to_s.gsub(',','.'), :unit => unit }
      else
        parsed[:parameters][parameter] = value.to_s.gsub(',','.')
      end
      what_next, sentence, optional = find_missing_parameters(parsed)
      if what_next == params[:current_asking]
        return {:asking_again => "cancel"}
      end
      return  { :parsed => parsed, :asking_again => what_next, :sentence => sentence, :optional => optional}
    end

    def handle_modify_quantity_tav(params)
      parsed = params[:parsed]
      new_params = {}
      content, new_params = extract_quantity(params[:user_input].downcase, new_params)
      content, new_params = extract_conflicting_degrees(content, new_params)
      content, new_params = extract_tav(content, new_params)
      if !new_params['quantity'].nil?
        parsed[:parameters]['quantity'] = new_params['quantity']
      end
      if !new_params['tav'].nil?
        parsed[:parameters]['tav'] = new_params['tav']
      end
      parsed[:user_input] = params[:parsed][:user_input] << ' - (Tavp) ' << params[:user_input]
      what_next, sentence, optional = find_missing_parameters(parsed)
      if what_next == params[:current_asking]
        return {:asking_again => "cancel"}
      end
      return  { :parsed => parsed, :asking_again => what_next, :sentence => sentence, :optional => optional}
    end

    def handle_modify_date(params)
      parsed = params[:parsed]
      duration, user_input = extract_duration_fr(params[:user_input].downcase)
      intervention_date, user_input = extract_date_fr(user_input)
      parsed[:duration] = choose_duration(duration, parsed[:duration])
      parsed[:intervention_date] = choose_date(intervention_date, parsed[:intervention_date])
      parsed[:user_input] = params[:parsed][:user_input] << ' - (Temporalité) ' << params[:user_input]
      what_next, sentence, optional = find_missing_parameters(parsed)
      if what_next == params[:current_asking]
        return {:asking_again => "cancel"}
      end
      return  { :parsed => parsed, :asking_again => what_next, :sentence => sentence, :optional => optional}
    end

    def handle_parse_destination_quantity(params)
      parsed = params[:parsed]
      parameter = params[:parameter]
      value = params[parameter]
      if value.nil?
        hasNumbers = params[:user_input].match('\d{1,4}((\.|,)\d{1,2})?')
        if hasNumbers
          value = hasNumbers[0].gsub(',','.').gsub(' ','')
        else
          return {:asking_again => "cancel"}
        end
      # If we have a value, we should check if watson didn't return an integer instead of a float
      elsif params[:user_input].match(/#{value}(\.\d{1,2})/)
        new_value_matches = params[:user_input].match(/#{value}(\.\d{1,2})/)
        value = new_value_matches[0]
      end
      parsed[:destination][params[:optional]][:quantity] = value.to_s.gsub(',','.')
      parsed[:user_input] += ' - (Quantité) ' << params[:user_input]
      what_next, sentence, optional = find_missing_parameters(parsed)
      if what_next == params[:current_asking] and optional == params[:optional]
        return {:asking_again => "cancel"}
      end
      return  { :parsed => parsed, :asking_again => what_next, :sentence => sentence, :optional => optional}
    end

    def handle_parse_targets(params)
      parsed = params[:parsed]
      Ekylibre::Tenant.switch params['tenant'] do
        targets = []
        user_inputs_combos = self.create_words_combo(params[:user_input].downcase)
        # Iterate through all user's combo of words (with their indexes)
        user_inputs_combos.each do |index, combo|
          # Define minimum matching level, initialize saved_hash and recognized list to None
          level = 0.90
          saved_hash = nil
          list = nil
          # Iterating through varieties
          Plant.availables(at: parsed[:intervention_date]).uniq.each do |pl|
            level, saved_hash, list = compare_elements(combo, pl[:name], index, level, pl[:id], targets, saved_hash, list)
          end
          # If we recognized something, we append it to the correct list and we remove what matched from the user_input
          unless saved_hash.nil?
            list = add_to_recognize_final(saved_hash, list, [targets])
          end
        end
        targets = extract_plant_area(params[:user_input].downcase, targets)
        parsed[:targets] = targets
      end
      parsed[:user_input] += ' - (Cibles) ' << params[:user_input]
      what_next, sentence, optional = find_missing_parameters(parsed)
      if what_next == params[:current_asking]
        return {:asking_again => "cancel"}
      end
      return  { :parsed => parsed, :asking_again => what_next, :sentence => sentence, :optional => optional}
    end

    def handle_parse_destination(params)
      parsed = params[:parsed]
      Ekylibre::Tenant.switch params['tenant'] do
        destination = []
        user_inputs_combos = self.create_words_combo(params[:user_input].downcase)
        # Iterate through all user's combo of words (with their indexes)
        user_inputs_combos.each do |index, combo|
          # Define minimum matching level, initialize saved_hash and recognized list to None
          level = 0.90
          saved_hash = nil
          list = nil
          # Iterating through varieties
          Equipment.availables(at: parsed[:intervention_date]).where("variety='tank'").each do |tank|
            level, saved_hash, list = compare_elements(combo, tank[:name], index, level, tank[:id], destination, saved_hash, list)
          end
          # If we recognized something, we append it to the correct list and we remove what matched from the user_input
          unless saved_hash.nil?
            list = add_to_recognize_final(saved_hash, list, [destination])
          end
        end
        parsed[:destination] = destination
      end
      parsed[:user_input] += ' (Destination) ' << params[:user_input]
      what_next, sentence, optional = find_missing_parameters(parsed)
      if what_next == params[:current_asking] and optional == params[:optional]
        return {:asking_again => "cancel"}
      end
      return  { :parsed => parsed, :asking_again => what_next, :sentence => sentence, :optional => optional}
    end

    def handle_add_other(params)
      Ekylibre::Tenant.switch params['tenant'] do
        new_targets = []
        new_species = []
        new_destination = [] # Cellar Press
        # Finding when it happened and how long it lasted, + getting cleaned user_input
        duration, user_input = extract_duration_fr(params[:user_input].downcase)
        intervention_date, user_input = extract_date_fr(user_input)
        new_date = choose_date(params[:parsed][:intervention_date], intervention_date)
        new_duration = choose_duration(params[:parsed][:duration], duration)
        # Create all combos of 1 to 4 words from the inputs , with their indexes, to use for matching
        user_inputs_combos = self.create_words_combo(user_input)
        # Iterate through all user's combo of words (with their indexes)
        user_inputs_combos.each do |index, combo|
          # Define minimum matching level, initialize saved_hash and recognized list to None
          level = 0.90
          saved_hash = nil
          list = nil
          # Iterating through varieties
          Plant.availables(at: new_date).each do |pl|
            level, saved_hash, list = compare_elements(combo, pl['specie_variety']['specie_variety_name'], index, level, pl['specie_variety']['specie_variety_name'], new_species, saved_hash, list)
            level, saved_hash, list = compare_elements(combo, pl[:name], index, level, pl[:id], new_targets, saved_hash, list)
          end
          Equipment.availables(at: new_date).where("variety='tank'").each do |tank|
            level, saved_hash, list = compare_elements(combo, tank[:name], index, level, tank[:name], new_destination, saved_hash, list)
          end
          # If we recognized something, we append it to the correct list and we remove what matched from the user_input
          unless saved_hash.nil?
            list = add_to_recognize_final(saved_hash, list, [new_targets, new_species, new_destination])
          end
        end
        new_targets = extract_plant_area(user_input.downcase, new_targets)
        parsed = {:targets =>  uniq_conc(new_targets,params[:parsed][:targets].to_a),
                  :species =>  uniq_conc(new_species,params[:parsed][:species].to_a),
                  :destination => uniq_conc(new_destination, params[:parsed][:destination].to_a),
                  :parameters => params[:parsed][:parameters],
                  :duration => new_duration,
                  :intervention_date => new_date,
                  :user_input => params[:parsed][:user_input] << ' - (Autre) ' << params[:user_input]}
        # Find if crucials parameters haven't been given, to ask again to the user
        what_next, sentence, optional = find_missing_parameters(parsed)
        return  { :parsed => parsed, :asking_again => what_next, :sentence => sentence, :optional => optional}
      end
    end

    def handle_add_analysis(params)
      user_input, new_parameters = extract_reception_parameters(params[:user_input])
      new_parameters = concatenate_analysis(params[:parsed][:parameters], new_parameters)
      parsed = {:targets =>  params[:parsed][:targets],
                :species =>  params[:parsed][:species],
                :destination => params[:parsed][:destination],
                :parameters => new_parameters,
                :duration => params[:parsed][:duration],
                :intervention_date => params[:parsed][:intervention_date],
                :user_input => params[:parsed][:user_input] << ' - (Analyse) ' << params[:user_input]}
        # Find if crucials parameters haven't been given, to ask again to the user
        what_next, sentence, optional = find_missing_parameters(parsed)
        return  { :parsed => parsed, :asking_again => what_next, :sentence => sentence, :optional => optional}
    end

    def handle_add_pressing(params)
      new_parameters = params[:parsed][:parameters]
      pressing_date, user_input = extract_date_fr(params[:user_input])
      new_parameters['pressing'] = {'hour' => pressing_date, 'program' => user_input}
      parsed = {:targets =>  params[:parsed][:targets],
                :species =>  params[:parsed][:species],
                :destination => params[:parsed][:destination],
                :parameters => new_parameters,
                :duration => params[:parsed][:duration],
                :intervention_date => params[:parsed][:intervention_date],
                :user_input => params[:parsed][:user_input] << ' - (Pressurage) ' << params[:user_input]}
        # Find if crucials parameters haven't been given, to ask again to the user
        what_next, sentence, optional = find_missing_parameters(parsed)
        return  { :parsed => parsed, :asking_again => what_next, :sentence => sentence, :optional => optional}
    end

    def handle_save_harvest_reception(params)
      parsed = params[:parsed]
      Ekylibre::Tenant.switch params['tenant'] do
        # Checking recognized storages
        storages_attributes = {}
        if parsed[:destination].to_a.length == 1
          # If there's only one destination, entry quantity is the destination quantity in hectoliters
          storages_attributes["0"] = {"storage_id" => parsed[:destination][0][:key],"quantity_value" =>
          unit_to_hectoliter(parsed[:parameters]['quantity']['rate'],parsed[:parameters]['quantity']['unit']),
          "quantity_unit" => "hectoliter"}
        else
          parsed[:destination].to_a.each_with_index do |cuve, index|
            storages_attributes[index] = {"storage_id"=> cuve[:key], "quantity_value"=>cuve[:quantity], "quantity_unit" => "hectoliter"}
          end
        end
        # Checking recognized targets
        targets_attributes = {}
        parsed[:targets].to_a.each_with_index do |target, index|
            targets_attributes[index] = {"plant_id" => target[:key], "harvest_percentage_received" => target[:area].to_s}
        end
        # Checking secondary parameters
        duration = params[:parsed][:duration].to_i
        intervention_date = params[:parsed][:intervention_date]
        # If unit is "ton" multiply quantity by 1000
        if parsed[:parameters]['quantity']['unit'] == "tonne"
          parsed[:parameters]['quantity']['rate'] *= 1000
        end

        analysis = Analysis.create!({
         nature: "vine_harvesting_analysis",
         analysed_at: Time.zone.parse(intervention_date),
         sampled_at: Time.zone.parse(intervention_date),
         items_attributes: create_analysis_attributes(parsed)}
        )

        incomingHarvest = IncomingHarvest.create!({
          received_at: Time.zone.parse(intervention_date),
          storages_attributes: storages_attributes,
          quantity_value: parsed[:parameters]['quantity']['rate'].to_s,
          quantity_unit: ("kilogram" if ["kg","tonne"].include?(parsed[:parameters]['quantity']['unit' ])) || "hectoliter",
          analysis: analysis,
          plants_attributes: targets_attributes,
          pressing_schedule: (parsed[:parameters]['pressing']['program'] if !parsed[:parameters]['pressing'].nil?) || "",
          pressing_started_at: (parsed[:parameters]['pressing']['hour'] if !parsed[:parameters]['pressing'].nil?) || ""})

        return {"link" => "\\backend\\incoming_harvests\\"+incomingHarvest['id'].to_s}
      end
    end
  end
end
