module Duke
  class HarvestReceptions < Duke::DukeParsing

    def handle_parse_sentence(params)
      Ekylibre::Tenant.switch params['tenant'] do
        targets = []
        crop_groups = []
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
          # Define minimum matching level, initialize matching_element and recognized matching_list to None
          level = 0.90
          matching_element = nil
          matching_list = nil
          # Iterating through varieties
          Plant.availables(at: intervention_date).each do |pl|
            level, matching_element, matching_list = compare_elements(combo, pl['specie_variety']['specie_variety_name'], index, level, pl['specie_variety']['specie_variety_name'], species, matching_element, matching_list)
            level, matching_element, matching_list = compare_elements(combo, pl[:name], index, level, pl[:id], targets, matching_element, matching_list)
          end
          CropGroup.all.where("target = 'plant'").each do |cropg|
            level, matching_element, matching_list = compare_elements(combo, cropg[:name], index, level, cropg[:id], crop_groups, matching_element, matching_list)
          end
          Matter.availables(at: intervention_date).where("variety='tank'").each do |tank|
            level, matching_element, matching_list = compare_elements(combo, tank[:name], index, level, tank[:id], destination, matching_element, matching_list)
          end
          # If we recognized something, we append it to the correct matching_list and we remove what matched from the user_input
          unless matching_element.nil?
            matching_list = add_to_recognize_final(matching_element, matching_list, [targets, species, destination, crop_groups], user_input)
          end
        end
        targets, crop_groups = extract_plant_area(user_input, targets, crop_groups)
        parsed = {:targets => targets,
                  :crop_groups => crop_groups,
                  :species => species,
                  :destination => destination,
                  :parameters => parameters,
                  :duration => duration,
                  :intervention_date => intervention_date,
                  :user_input => params[:user_input]}
        parsed[:ambiguities] = find_ambiguity(parsed, user_input)
        # Find if crucials parameters haven't been given, to ask again to the user
        what_next, sentence, optional = find_missing_parameters(parsed)
        return  { :parsed => parsed, :asking_again => what_next, :sentence => sentence, :optional => optional}
      end
    end

    def handle_parse_parameter(params)
      parsed = params[:parsed]
      parameter = params[:parameter]
      value = params[parameter]
      match_to_float = params[:user_input].match(/#{value}(\.\d{1,2})/) unless value.nil?
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
      elsif match_to_float
        value = match_to_float[0]
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
        parsed[:parameters][parameter] = {:rate => value.to_s.gsub(',','.').to_f, :unit => unit }
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
      unless new_params['quantity'].nil?
        parsed[:parameters]['quantity'] = new_params['quantity']
      end
      unless new_params['tav'].nil?
        parsed[:parameters]['tav'] = new_params['tav']
      end
      parsed[:user_input] = params[:parsed][:user_input] << ' - ' << params[:user_input]
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
      parsed[:user_input] = params[:parsed][:user_input] << ' - ' << params[:user_input]
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
        crop_groups = []
        user_inputs_combos = self.create_words_combo(params[:user_input].downcase)
        # Iterate through all user's combo of words (with their indexes)
        user_inputs_combos.each do |index, combo|
          # Define minimum matching level, initialize matching_element and recognized matching_list to None
          level = 0.90
          matching_element = nil
          matching_list = nil
          # Iterating through varieties
          Plant.availables(at: parsed[:intervention_date]).uniq.each do |pl|
            level, matching_element, matching_list = compare_elements(combo, pl[:name], index, level, pl[:id], targets, matching_element, matching_list)
          end
          CropGroup.all.where("target = 'plant'").each do |cropg|
            level, matching_element, matching_list = compare_elements(combo, cropg[:name], index, level, cropg[:id], crop_groups, matching_element, matching_list)
          end
          # If we recognized something, we append it to the correct matching_list and we remove what matched from the user_input
          unless matching_element.nil?
            matching_list = add_to_recognize_final(matching_element, matching_list, [targets, crop_groups], params[:user_input].downcase)
          end
        end
        targets, crop_groups = extract_plant_area(params[:user_input].downcase, targets, crop_groups)
        # If there's no new Target/Crop_group, But a percentage, it's the new area % foreach previous target
        if crop_groups.empty? and targets.empty?
          pct_regex = params[:user_input].downcase.match(/(\d{1,2}) *(%|pour( )?cent(s)?)/)
          if pct_regex
            parsed[:crop_groups].to_a.each { |crop_group| crop_group[:area] = pct_regex[1]}
            parsed[:targets].to_a.each { |target| target[:area] = pct_regex[1]}
          end
        else
          parsed[:targets] = targets
          parsed[:crop_groups] = crop_groups
          parsed[:ambiguities] = find_ambiguity({:targets => targets, :crop_groups => crop_groups}, params[:user_input])
        end
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
          # Define minimum matching level, initialize matching_element and recognized matching_list to None
          level = 0.90
          matching_element = nil
          matching_list = nil
          # Iterating through varieties
          Matter.availables(at: parsed[:intervention_date]).where("variety='tank'").each do |tank|
            level, matching_element, matching_list = compare_elements(combo, tank[:name], index, level, tank[:id], destination, matching_element, matching_list)
          end
          # If we recognized something, we append it to the correct matching_list and we remove what matched from the user_input
          unless matching_element.nil?
            matching_list = add_to_recognize_final(matching_element, matching_list, [destination], params[:user_input].downcase)
          end
        end
        parsed[:destination] = destination
        parsed[:ambiguities] = find_ambiguity({:destination => destination}, params[:user_input])
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
        new_crop_groups = []
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
          # Define minimum matching level, initialize matching_element and recognized matching_list to None
          level = 0.90
          matching_element = nil
          matching_list = nil
          # Iterating through varieties
          Plant.availables(at: new_date).each do |pl|
            level, matching_element, matching_list = compare_elements(combo, pl['specie_variety']['specie_variety_name'], index, level, pl['specie_variety']['specie_variety_name'], new_species, matching_element, matching_list)
            level, matching_element, matching_list = compare_elements(combo, pl[:name], index, level, pl[:id], new_targets, matching_element, matching_list)
          end
          CropGroup.all.where("target = 'plant'").each do |cropg|
            level, matching_element, matching_list = compare_elements(combo, cropg[:name], index, level, cropg[:id], new_crop_groups, matching_element, matching_list)
          end
          Matter.availables(at: new_date).where("variety='tank'").each do |tank|
            level, matching_element, matching_list = compare_elements(combo, tank[:name], index, level, tank[:id], new_destination, matching_element, matching_list)
          end
          # If we recognized something, we append it to the correct matching_list and we remove what matched from the user_input
          unless matching_element.nil?
            matching_list = add_to_recognize_final(matching_element, matching_list, [new_targets, new_species, new_destination, new_crop_groups], user_input)
          end
        end
        new_targets, new_crop_groups = extract_plant_area(user_input.downcase, new_targets, new_crop_groups)
        parsed = {:targets =>  uniq_conc(new_targets,params[:parsed][:targets].to_a),
                  :crop_groups => uniq_conc(new_crop_groups, params[:parsed][:crop_groups].to_a),
                  :species =>  uniq_conc(new_species,params[:parsed][:species].to_a),
                  :destination => uniq_conc(new_destination, params[:parsed][:destination].to_a),
                  :parameters => params[:parsed][:parameters],
                  :duration => new_duration,
                  :intervention_date => new_date,
                  :user_input => params[:parsed][:user_input] << ' - (Autre) ' << params[:user_input]}
        parsed[:ambiguities] = find_ambiguity({:destination => new_destination, :crop_groups => new_crop_groups, :targets => new_targets}, params[:user_input])
        # Find if crucials parameters haven't been given, to ask again to the user
        what_next, sentence, optional = find_missing_parameters(parsed)
        return  { :parsed => parsed, :asking_again => what_next, :sentence => sentence, :optional => optional}
      end
    end

    def handle_parse_disambiguation(params)
      parsed = params[:parsed]
      ambElement = params[:optional][-1]
      ambType, ambArray = parsed.find { |key, value| value.is_a?(Array) and value.any? { |subhash| subhash[:name] == ambElement[:name]}}
      ambHash = ambArray.find {|hash| hash[:name] == ambElement[:name]}
      begin
        chosen_one = eval(params[:user_input])
        ambHash[:name] = chosen_one["name"]
        ambHash[:key] = chosen_one["key"]
      rescue
        if params[:user_input] == "Tous"
          params[:optional].each_with_index do |ambiguate, index|
            unless index+1 == params[:optional].length
              hashClone = ambHash.clone()
              hashClone[:name] = ambiguate[:name]
              hashClone[:key] = ambiguate[:key]
              ambArray.push(hashClone)
            end
          end
        end
      ensure
        parsed[:ambiguities].shift
        what_next, sentence, optional = find_missing_parameters(parsed)
        return  { :parsed => parsed, :asking_again => what_next, :sentence => sentence, :optional => optional}
      end
    end

    def handle_add_analysis(params)
      user_input, new_parameters = extract_reception_parameters(params[:user_input])
      new_parameters = concatenate_analysis(params[:parsed][:parameters], new_parameters)
      params[:parsed][:parameters] = new_parameters
      params[:parsed][:user_input] += " - (Analyse) #{params[:user_input]}"
      # Find if crucials parameters haven't been given, to ask again to the user
      what_next, sentence, optional = find_missing_parameters(parsed)
      return  { :parsed => params[:parsed], :asking_again => what_next, :sentence => sentence, :optional => optional}
    end

    def handle_add_input(params)
      new_parameters = params[:parsed][:parameters]
      new_parameters['co2'] = extract_co2(params[:user_input].downcase)
      new_parameters['so2'] = extract_SO2(params[:user_input].downcase)
      params[:parsed][:parameters] = new_parameters
      params[:parsed][:user_input] += " - (Intrant) params[:user_input]"
        # Find if crucials parameters haven't been given, to ask again to the user
        what_next, sentence, optional = find_missing_parameters(parsed)
        return  { :parsed => params[:parsed], :asking_again => what_next, :sentence => sentence, :optional => optional}
    end

    def handle_add_pressing(params)
      new_parameters = params[:parsed][:parameters]
      pressing_date, user_input = extract_date_fr(params[:user_input])
      new_parameters['pressing'] = {'hour' => pressing_date, 'program' => user_input}
      params[:parsed][:parameters] = new_parameters
      params[:parsed][:user_input] += " - (Pressurage) params[:user_input]"
      # Find if crucials parameters haven't been given, to ask again to the user
      what_next, sentence, optional = find_missing_parameters(parsed)
      return  { :parsed => params[:parsed], :asking_again => what_next, :sentence => sentence, :optional => optional}
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
        # Checking recognized targets & crop_groups
        targets_attributes = {}
        parsed[:targets].to_a.each_with_index do |target, index|
          targets_attributes[index] = {"plant_id" => target[:key], "harvest_percentage_received" => target[:area].to_s}
        end
        parsed[:crop_groups].to_a.each_with_index do |cropgroup, index|
          CropGroup.available_crops(cropgroup[:key], "is plant").each_with_index do |crop, index2|
              targets_attributes["#{index}#{index2}"] = {"plant_id" => crop[:id], "harvest_percentage_received" => cropgroup[:area].to_s}
          end
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
