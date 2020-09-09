module Duke
  class Interventions < Duke::DukeParsing

    def handle_parse_sentence(params)
      Ekylibre::Tenant.switch params['tenant'] do
        procedure = params['procedure']
        return if Procedo::Procedure.find(procedure).nil?
        equipments = []
        workers = []
        inputs = []
        crop_groups = []
        # Finding when it happened and how long it lasted, + getting cleaned user_input
        user_input = clear_string(params[:user_input])
        duration, user_input = extract_duration_fr(user_input)
        intervention_date, user_input = extract_date_fr(user_input)
        # Create all combos of 1 to 4 words from the inputs , with their indexes, to use for matching
        user_inputs_combos = self.create_words_combo(user_input)
        # Iterate through all user's combo of words (with their indexes)
        user_inputs_combos.each do |index, combo|
          # Define minimum matching level, initialize matching_element and matching_list to None
          level = 0.89
          matching_element = nil # A Hash containing :key, :name, :indexes, :distance,
          matching_list = nil  # A pointer, which will point to the list on which to add the matching element, if a match occurs, else points to nothing
          # Iterating through workers : Search for full name and first name only
          Worker.availables(at: intervention_date).each do |worker|
            level, matching_element, matching_list = compare_elements(combo, worker[:name], index, level, worker[:id], workers, matching_element, matching_list)
            level, matching_element, matching_list = compare_elements(combo, worker[:name].split[0], index, level, worker[:id], workers, matching_element, matching_list)
          end
          # Iterating through equipments
          Equipment.availables(at: intervention_date).each do |eq|
            level, matching_element, matching_list = compare_elements(combo, eq[:name], index, level, eq[:id], equipments, matching_element, matching_list)
          end
          # Iterating through inputs if the procedure type includes inputs
          unless Procedo::Procedure.find(procedure).parameters_of_type(:input).empty?
            #TODO: Find nature_id of the current procedure
            Matter.availables(at: intervention_date).where("nature_id=45").each do |input|
              level, matching_element, matching_list = compare_elements(combo, input[:name], index, level, input[:id], inputs, matching_element, matching_list)
            end
          end
          # Iterating through crop groups
          CropGroup.all.each do |cropg|
            level, matching_element, matching_list = compare_elements(combo, cropg[:name], index, level, cropg[:id], crop_groups, matching_element, matching_list)
          end
          # If we recognized something, we append it to the correct matching_list and we remove what matched from the user_input
          unless matching_element.nil?
            matching_list = add_to_recognize_final(matching_element, matching_list, [equipments,workers,inputs,crop_groups], user_input)
          end
        end
        add_input_rate(user_input, inputs)
        parsed = {:inputs => inputs,
                  :workers => workers,
                  :equipments => equipments,
                  :crop_groups => crop_groups,
                  :procedure => procedure,
                  :duration => duration,
                  :intervention_date => intervention_date,
                  :user_input => params[:user_input]}

        return  { :parsed => parsed,
                :sentence => speak_intervention(parsed) }
      end
    end

    def handle_add_information(params)
      Ekylibre::Tenant.switch params['tenant'] do
        new_equipments = []
        new_workers = []
        new_inputs = []
        new_crop_groups = []
        procedure = params[:parsed][:procedure]
        user_input = clear_string(params[:user_input])
        user_inputs_combos = create_words_combo(user_input)
        user_inputs_combos.each do |index, combo|
          # Define minimum matching level, initialize matching_element and recognized matching_list to None
          level = 0.90
          matching_element = nil
          matching_list = nil
          # Iterating through equipments
          Worker.availables(at: params[:parsed][:intervention_date]).each do |worker|
            level, matching_element, matching_list = compare_elements(combo, worker[:name], index, level, worker[:id], new_workers, matching_element, matching_list)
            level, matching_element, matching_list = compare_elements(combo, worker[:name].split[0], index, level, worker[:id], new_workers, matching_element, matching_list)
          end
          unless Procedo::Procedure.find(procedure).parameters_of_type(:input).empty?
            Matter.availables(at: params[:parsed][:intervention_date]).where("nature_id=45").each do |input|
              level, matching_element, matching_list = compare_elements(combo, input[:name], index, level, input[:id], new_inputs, matching_element, matching_list)
            end
          end
          CropGroup.all.each do |cropg|
            level, matching_element, matching_list = compare_elements(combo, cropg[:name], index, level, cropg[:id], new_crop_groups, matching_element, matching_list)
          end
          Equipment.availables(at: params[:parsed][:intervention_date]).each do |eq|
            level, matching_element, matching_list = compare_elements(combo, eq[:name], index, level, eq[:id], new_equipments, matching_element, matching_list)
          end
          # If we recognized something, and there's no interferences, we append it to the correct matching_list
          unless matching_element.nil?
            add_to_recognize_final(matching_element, matching_list, [new_equipments,new_workers,new_inputs,new_crop_groups], user_input)
          end
        end
        add_input_rate(user_input, new_inputs)
        parsed = {:inputs => uniq_conc(new_inputs,params[:parsed][:inputs].to_a),
                  :workers => uniq_conc(new_workers,params[:parsed][:workers].to_a),
                  :equipments => uniq_conc(new_equipments,params[:parsed][:equipments].to_a),
                  :crop_groups =>  uniq_conc(new_crop_groups,params[:parsed][:crop_groups].to_a),
                  :procedure => params[:parsed][:procedure],
                  :duration => params[:parsed][:duration],
                  :intervention_date => params[:parsed][:intervention_date],
                  :user_input => params[:parsed][:user_input] << ' - ' << params[:user_input]}

        return  {:sentence =>  speak_intervention(parsed),
                 :parsed => parsed }
     end
    end

    def handle_save_intervention(params)
      Ekylibre::Tenant.switch params['tenant'] do
        tools_attributes = []
        params[:parsed][:equipments].to_a.each do |tool|
          tools_attributes.push({"reference_name" => Procedo::Procedure.find(params[:parsed][:procedure]).parameters_of_type(:tool)[0].name, 'product_id' => tool[:key]})
        end
        doers_attributes = []
        params[:parsed][:workers].to_a.each do |worker|
          doers_attributes.push({"reference_name" => Procedo::Procedure.find(params[:parsed][:procedure]).parameters_of_type(:doer)[0].name, "product_id" => worker[:key]})
        end
        inputs_attributes = []
        unless Procedo::Procedure.find(params[:parsed][:procedure]).parameters_of_type(:input).empty?
          params[:parsed][:inputs].to_a.each do |input|
            inputs_attributes.push({"reference_name" => Procedo::Procedure.find(params[:parsed][:procedure]).parameters_of_type(:input)[0].name,
                                               "product_id" => input[:input][:key],
                                               "quantity_value" => input[:rate][:value],
                                               "quantity_population" => input[:rate][:value],
                                               "quantity_handler" => input[:rate][:unit]})
          end
        end
        targets_attributes = []
        params[:parsed][:crop_groups].to_a.each do |cropgroup|
          CropGroup.available_crops(cropgroup[:key], "is plant").each do |crop|
            targets_attributes.push({"reference_name" => Procedo::Procedure.find(params[:parsed][:procedure]).parameters_of_type(:target)[0].name, "product_id" => crop[:id]})
          end
        end
        duration = params[:parsed][:duration].to_i
        intervention_date = params[:parsed][:intervention_date]

        intervention = Intervention.create!(procedure_name: params[:parsed][:procedure],
                                            description: 'Duke : ' << params[:parsed][:user_input],
                                            state: 'done',
                                            number: '50',
                                            nature: 'record',
                                            tools_attributes: tools_attributes,
                                            doers_attributes: doers_attributes,
                                            targets_attributes: targets_attributes,
                                            inputs_attributes: inputs_attributes,
                                            working_periods_attributes:   [ { "started_at": Time.zone.parse(intervention_date) - duration.minutes, "stopped_at": intervention_date}])
        return {"link" => "\\backend\\interventions\\"+intervention['id'].to_s}
      end
    end
  end
end
