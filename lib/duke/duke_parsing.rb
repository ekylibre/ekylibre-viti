module Duke
  class DukeParsing
    @@fuzzloader = FuzzyStringMatch::JaroWinkler.create( :pure )

    # All functions that are creating sentences for Duke to respond

    def create_intervention_sentence(params)
      # Create validation sentence for InterventionSkill
      I18n.locale = :fra
      sentence = I18n.t("duke.interventions.save_intervention_#{rand(0...3)}")
      sentence += "#{Procedo::Procedure.find(params[:procedure]).human_name}"
      sentence += "#{speak_inputs(params[:inputs])}#{speak_tool(params[:equipments])}#{speak_crop_groups(params[:crop_groups])}#{speak_workers(params[:workers])}"
      return sentence
    end

    def create_reception_sentence(params)
      # Create validation sentence for HarvestReceptionSkill
      I18n.locale = :fra
      sentence = I18n.t("duke.harvest_reception.save_harvest_reception_#{rand(0...2)}")
      sentence+= "<br>&#8226 Culture(s) : "
      params[:targets].each do |target|
        sentence += target[:area].to_s+"% "+target[:name]+", "
      end
      sentence+= "<br>&#8226 Quantité : "+params[:parameters]['quantity']['rate'].to_s+" "+params[:parameters]['quantity']['unit']
      sentence+= "<br>&#8226 Date : "+params[:intervention_date].to_datetime.strftime("%d/%m/%Y - %H:%M")
      sentence+= "<br>&#8226 Destination : "
      params[:destination].each do |destination|
        sentence+= destination[:name]
        if destination.key?('quantity')
          sentence+= ' ('+destination[:quantity].to_s+' hl)'
        end
        sentence+=', '
      end
      sentence+= "<br>&#8226 TAVP : "+params[:parameters]['tav'].to_s+" % vol"
      if !params[:parameters]['temperature'].nil?
        sentence+= "<br>&#8226 Température : "+params[:parameters]['temperature']+ "°C"
      end
      if !params[:parameters]['h2so4'].nil?
        sentence+= "<br>&#8226 H2SO4 : "+params[:parameters]['h2so4']
      end
      if !params[:parameters]['ph'].nil?
        sentence+= "<br>&#8226 pH : "+params[:parameters]['ph']
      end
      if !params[:parameters]['nitrogen'].nil?
        sentence+= "<br>&#8226 Azote : "+params[:parameters]['nitrogen']
      end
      if !params[:parameters]['operatorymode'].nil?
        sentence+= "<br>&#8226 Mode Opératoire : "+params[:parameters]['operatorymode']
      end
      if !params[:parameters]['pressing'].nil?
        sentence+= "<br>&#8226 Pressurage spécifié"
      end
      # speaking inputs
      return sentence
    end

    def create_destination_quantity_sentence(params)
      # Function that create sentence to ask for quantity in a specific destination
      # Return the sentence, and the index of the destination inside params[:destination] as an optional value
      I18n.locale = :fra
      sentence = I18n.t("duke.harvest_reception.how_much_to_#{rand(0...2)}")
      params[:destination].each_with_index do |cuve, index|
        if not cuve.key?("quantity")
          sentence += cuve[:name]
          return sentence, index
        end
      end
    end

    def speak_species(reco_species)
      # Function that helps speak species in interventionSkill
      if reco_species.nil?
        return ""
      elsif reco_species.length() == 0
        return ""
      elsif reco_species.length() == 1
        return " de variété "+reco_species[0]['name']
      elsif reco_species.length() == 2
        return " de variété "+reco_species[0][:name]+" et "+reco_species[1][:name]
      elsif reco_species.length() == 3
        return " de variété "+reco_species[0][:name]+", "+reco_species[1][:name]+" et "+reco_species[2][:name]
      else
        return " avec "+ reco_species.length().to_s+" variétés"
      end
    end


    def speak_tool(reco_equipment)
      # Function that helps speak tools in interventionSkill
      if reco_equipment.length() == 0
        return ""
      elsif reco_equipment.length() == 1
        return " avec l'outil "+reco_equipment[0][:name]
      elsif reco_equipment.length() == 2
        return " avec les outils "+reco_equipment[0][:name]+" et "+reco_equipment[1][:name]
      elsif reco_equipment.length() == 3
        return " avec les outils "+reco_equipment[0][:name]+", "+reco_equipment[1][:name]+" et "+reco_equipment[2][:name]
      else
        return " avec "+ reco_equipment.length().to_s+" outils"
      end
    end


    def speak_crop_groups(reco_crop_groups)
      # Function that helps speak crop_groups in interventionSkill
      if reco_crop_groups.length() == 0
        return ""
      elsif reco_crop_groups.length() == 1
        return " sur "+reco_crop_groups[0][:name]
      elsif reco_crop_groups.length() == 2
        return " sur "+reco_crop_groups[0][:name]+" et "+reco_crop_groups[1][:name]
      elsif reco_crop_groups.length() == 3
        return " sur "+reco_crop_groups[0][:name]+", "+reco_crop_groups[1][:name]+" et "+reco_crop_groups[2][:name]
      else
        return " sur "+ reco_crop_groups.length().to_s+" regroupements de parcelles"
      end
    end


    def speak_workers(reco_workers)
      # Function that helps speak workers in interventionSkill
      if reco_workers.nil?
        return ""
      elsif reco_workers.length() == 0
        return ""
      elsif reco_workers.length() == 1
        return " par "+reco_workers[0][:name]
      elsif reco_workers.length() == 2
        return " par "+reco_workers[0][:name]+" et "+reco_workers[1][:name]
      elsif reco_workers.length() == 3
        return " par "+reco_workers[0][:name]+", "+reco_workers[1][:name]+" et "+reco_workers[2][:name]
      else
        return " par "+ reco_workers.length().to_s+" travailleurs"
      end
    end


    def speak_inputs(reco_inputs)
      # Function that helps speak inputs in interventionSkill
      if reco_inputs.length() == 0
        return ""
      elsif reco_inputs.length() == 1
        return " de "+reco_inputs[0][:input][:name]
      elsif reco_inputs.length() == 2
        return " de "+reco_inputs[0][:input][:name]+" et de "+reco_inputs[1][:input][:name]
      elsif reco_inputs.length() == 3
        return " de "+reco_inputs[0][:input][:name]+", de "+reco_inputs[1][:input][:name]+" et de"+reco_inputs[2][:input][:name]
      else
        return " de "+ reco_inputs.length().to_s+" intrants"
      end
    end

    def create_analysis_attributes(parsed)
     return{"0"=>{"_destroy"=>"false", "indicator_name"=>"estimated_harvest_alcoholic_volumetric_concentration", "measure_value_value"=> parsed[:parameters]['tav'], "measure_value_unit"=>"volume_percent"},
            "1"=>{"_destroy"=>"false", "indicator_name"=>"potential_hydrogen", "decimal_value"=> (parsed[:parameters]['ph'] if !parsed[:parameters]['ph'].nil?) || "0.0"},
            "2"=>{"_destroy"=>"false", "indicator_name"=>"temperature", "measure_value_value"=> parsed[:parameters]['temperature'], "measure_value_unit"=>"celsius"},
            "3"=>{"_destroy"=>"false", "indicator_name"=>"assimilated_nitrogen_concentration", "measure_value_value"=> parsed[:parameters]['nitrogen'], "measure_value_unit"=>"milligram_per_liter"},
            "4"=>{"_destroy"=>"false", "indicator_name"=>"total_acid_concentration", "measure_value_value"=>parsed[:parameters]['h2so4'], "measure_value_unit"=>"gram_per_liter"},
            "5"=>{"_destroy"=>"false", "indicator_name"=>"malic_acid_concentration", "measure_value_value"=>parsed[:parameters]['malic'], "measure_value_unit"=>"gram_per_liter"},
            "6"=>{"_destroy"=>"false", "indicator_name"=>"sanitary_vine_harvesting_state", "string_value"=> (parsed[:parameters]['sanitarystate'] if !parsed[:parameters]['sanitarystate'].nil?) || "Rien à signaler" }}
    end
    # Extracting functions, regex / including

    def extract_duration_fr(content)
        #Function that finds the duration of the intervention & converts this value in minutes using regexes to have it stored into Ekylibre
        delta_in_mins = 0
        regex = '\d+\s(\w*minute\w*|mins)'
        regex2 = '(de|pendant|durée) *(\d)\s?(heures|h|heure)\s?(\d\d)'
        regex3 = '(de|pendant|durée) *(\d)\s?(h\b|h\s|heure)'
        if content.include? "1 quart d'heure"
          content["1 quart d'heure"] = ""
          return 15, content.strip.gsub(/\s+/, " ")
        end
        if content.include? "trois quarts d'heure"
          content["3 quart d'heure"] = ""
          return 45, content.strip.gsub(/\s+/, " ")
        end
        if content.include? "1 demi heure"
          content["1 demi heure"] = ""
          return 30, content.strip.gsub(/\s+/, " ")
        end
        min_time = content.match(regex)
        if min_time
          delta_in_mins += min_time[0].to_i
          content[min_time[0]] = ""
          return delta_in_mins, content.strip.gsub(/\s+/, " ")
        end
        hour_min_time = content.match(regex2)
        if hour_min_time
          delta_in_mins += hour_min_time[2].to_i*60
          delta_in_mins += hour_min_time[4].to_i
          content[hour_min_time[0]] = ""
          return delta_in_mins, content.strip.gsub(/\s+/, " ")
        end
        hour_time = content.match(regex3)
        if hour_time
          delta_in_mins += hour_time[2].to_i*60
          content[hour_time[0]] = ""
          if content.include? "et demi"
            delta_in_mins += 30
            content["et demi"] = ""
          end
          return delta_in_mins, content.strip.gsub(/\s+/, " ")
        end
        return 60, content.strip.gsub(/\s+/, " ")
    end

    def extract_date_fr(content)
      # Extract date from a string, and returns a dateTime object with appropriate date & time
      # Default value is Datetime.now
      now = DateTime.now
      month_hash = {"janvier" => 1, "février" => 2, "fevrier" => 2, "mars" => 3, "avril" => 4, "mai" => 5, "juin" => 6, "juillet" => 7, "août" => 8, "aout" => 8, "septembre" => 9, "octobre" => 10, "novembre" => 11, "décembre" => 12, "decembre" => 12 }
      full_date_regex = '(\d|\d{2})\s(janvier|février|fevrier|mars|avril|mai|juin|juillet|aout|août|septembre|octobre|novembre|décembre|decembre)(\s\d{4}|\s\b)'
      # Search for keywords
      if content.include? "avant-hier"
        content["avant-hier"] = ""
        d = Date.yesterday.prev_day
        time, content = extract_hour(content)
      elsif content.include? "hier"
        content["hier"] = ""
        d = Date.yesterday
        time, content = extract_hour(content)
      elsif content.include? "demain"
        content["demain"] = ""
        d = Date.tomorrow
        time, content = extract_hour(content)
      else
        time, content = extract_hour(content)
        # Then search for full date
        full_date = content.match(full_date_regex)
        if full_date
          content[full_date[0]] = ""
          day = full_date[1].to_i
          month = month_hash[full_date[2]]
          if full_date[3].to_i.between?(2015, 2021)
            year = full_date[3].to_i
          else
            year = Date.today.year
          end
          return DateTime.new(year, month, day, time.hour, time.min, time.sec, "+02:00"), content.strip.gsub(/\s+/, " ")
        else
          return DateTime.new(now.year, now.month, now.day, time.hour, time.min, time.sec, "+02:00"),  content.strip.gsub(/\s+/, " ")
        end
      end
      return DateTime.new(d.year, d.month, d.day, time.hour, time.min, time.sec, "+02:00"), content.strip.gsub(/\s+/, " ")
    end

    def extract_hour(content)
      # Extract hour from a string, returns a DateTime object with appropriate date
      # Default value is Time.now
      now = DateTime.now
      time_regex = '([5-9]|1[0-9]|2[03]) *(h|heure(s)?|:) *([0-5]?[0-9])'
      time = content.match(time_regex)
      if time
        content[time[0]] = ""
        return DateTime.new(now.year, now.month, now.day, time[1].to_i, time[4].to_i, 0), content
      elsif content.include? "matin"
        content["matin"] = ""
        return DateTime.new(now.year, now.month, now.day, 10, 0, 0), content
      elsif content.include? "après-midi"
        content["après-midi"] = ""
        return DateTime.new(now.year, now.month, now.day, 17, 0, 0), content
      elsif content.include? "midi"
        content["midi"] = ""
        return DateTime.new(now.year, now.month, now.day, 13, 0, 0), content
      elsif content.include? "soir"
        content["soir"] = ""
        return DateTime.new(now.year, now.month, now.day, 20, 0, 0), content
      else
        return DateTime.now, content
      end
    end

    def extract_quantity(content, parameters)
      # Extracting quantity data
      quantity_regex = '(\d{1,5}(\.|,)\d{1,2}|\d{1,5}) *(kilo|kg|hecto|hl|t\b|tonne)'
      quantity = content.match(quantity_regex)
      if quantity
        content[quantity[0]] = ""
        if quantity[3].match('(kilo|kg)')
          unit = "kg"
        elsif quantity[3].match('(hecto|hl)')
          unit = "hl"
        else
          unit = "tonne"
        end
        parameters['quantity'] = {"rate" => quantity[1].gsub(',','.').to_f, "unit" => unit} # rate is the first capturing group
      else
        parameters['quantity'] = nil
      end
      return content, parameters
    end

    def extract_conflicting_degrees(content, parameters)
      # Conflicts between TAV "degré" and temperature "degré", so we need to check first for explicit values
      second_tav_regex = '(degré d\'alcool|alcool|degré|tavp|tav|avp|t svp|pourcentage|t avait) *(est|était)? *(égal +(a *|à *)?|= *|de *|à *)?(\d{1,2}(\.|,)\d{1,2}|\d{1,2}) *(degré)?'
      second_temp_regex = '(température|temp) *(est|était)? *(égal *|= *|de *|à *)?(\d{1,2}(\.|,)\d{1,2}|\d{1,2}) *(degré)?'
      tav = content.match(second_tav_regex)
      if tav
        content[tav[0]] = ""
        parameters['tav'] = tav[5].gsub(',','.') # rate is the fifth capturing group
      end
      temp = content.match(second_temp_regex)
      if temp
        content[temp[0]] = ""
        parameters['temperature'] = temp[4].gsub(',','.') # temperature is the fourth capturing group
      end
      return content, parameters
    end

    def extract_tav(content, parameters)
      # Extracting tav data
      tav_regex = '(\d{1,2}|\d{1,2}(\.|,)\d{1,2}) +((degré(s)?|°|%) *(de *|en *)?(d\'|de|en) *(alcool)|(de|en|du) *(tav(p)?|avp|t svp|t avait))'
      tav = content.match(tav_regex)
      if not parameters.key?('tav')
        if tav
          content[tav[0]] = ""
          parameters['tav'] = tav[1].gsub(',','.') # rate is the first capturing group
        else
          parameters['tav'] = nil
        end
      end
      return content, parameters
    end

    def extract_temp(content, parameters)
      # Extracting temperature data
      temp_regex = '(\d{1,2}|\d{1,2}\.\d{1,2}) +(degré|°)'
      temp = content.match(temp_regex)
      if not parameters.key?('temperature')
        if temp
          content[temp[0]] = ""
          parameters['temperature'] = temp[1].gsub(',','.') # temperature is the first capturing group
        else
          parameters['temperature'] = nil
        end
      end
      return content, parameters
    end

    def extract_ph(content, parameters)
      # Extracting ph data
      ph_regex = '(\d{1,2}|\d{1,2}(\.|,)\d{1,2}) +(de +)?(ph|péage)'
      second_ph_regex = '((ph|péage) *(est|était)? *(égal *(a|à)? *|= ?|de +|à +)?)(\d{1,2}(\.|,)\d{1,2}|\d{1,2})'
      ph = content.match(ph_regex)
      if ph
        content[ph[0]] = ""
        parameters['ph'] = ph[1].gsub(',','.') # ph is the first capturing group
      elsif content.match(second_ph_regex)
        ph = content.match(second_ph_regex)
        content[ph[0]] = ""
        parameters['ph'] = ph[6].gsub(',','.') # ph is the third capturing group
      else
        parameters['ph'] = nil
      end
      return content, parameters
    end

    def extract_nitrogen(content, parameters)
      # Extracting nitrogen data
      nitrogen_regex = '(\d{1,3}|\d{1,3}(\.|,)\d{1,2}) +(mg|milligramme)?.?(par ml|\/ml|par millilitre)? ?+(d\'|de|en)? ?+(azote|sel d\'ammonium|substance(s)? azotée)'
      second_nitrogen_regex = '((azote|sel d\'ammonium|substance azotée) *(est|était)? *(égal +|= ?|de +)?(à)? *)(\d{1,3}(\.|,)\d{1,2}|\d{1,3})'
      nitrogen = content.match(nitrogen_regex)
      if nitrogen
        content[nitrogen[0]] = ""
        parameters['nitrogen'] = nitrogen[1].gsub(',','.') # nitrogen is the first capturing group
      elsif content.match(second_nitrogen_regex)
        nitrogen = content.match(second_nitrogen_regex)
        content[nitrogen[0]] = ""
        parameters['nitrogen'] = nitrogen[6].gsub(',','.') # nitrogen is the third capturing group
      else
        parameters['nitrogen'] = nil
      end
      return content, parameters
    end

    def extract_sanitarystate(content, parameters)
      # Extracting sanitary state data
      sanitarystate = ""
      if content.include? "sain " || content.include?("sein")
        sanitarystate += "sain "
      end
      if content.include?("botrytis") || content.include?("beau titre is")
        sanitarystate += "botrytis "
      end
      if content.include?("oidium") || content.include?("oïdium")
        content["dium"] = ""
        sanitarystate += "oïdium "
      end
      if content.include? "pourriture"
        content["pourriture"] = ""
        sanitarystate += "pourriture "
      end
      state = sanitarystate if sanitarystate != "" || nil
      parameters['sanitarystate'] = state
      return content, parameters
    end

    def extrat_h2SO4(content, parameters)
      # Extracting H2SO4 data
      h2so4_regex = '(\d{1,3}|\d{1,3}(\.|,)\d{1,2}) +(g|gramme)?.? *(par l|\/l|par litre)? ?+(d\'|de|en)? ?+(acidité|acide|h2so4)'
      second_h2so4_regex = '(acide|acidité|h2so4) *(est|était)? *(égal.? *(a|à)?|=|de|à|a)? *(\d{1,3}(\.|,)\d{1,2}|\d{1,3})'
      h2so4 = content.match(h2so4_regex)
      if h2so4
        content[h2so4[0]] = ""
        parameters['h2so4'] = h2so4[1].gsub(',','.') # h2so4 is the first capturing group
      elsif content.match(second_h2so4_regex)
        h2so4 = content.match(second_h2so4_regex)
        content[h2so4[0]] = ""
        parameters['h2so4'] = h2so4[5].gsub(',','.') # h2so4 is the third capturing group
      else
        parameters['h2so4'] = nil
      end
      return content, parameters
    end

    def extract_malic(content, parameters)
      # Extracting malic acid data
      malic_regex = '(\d{1,3}|\d{1,3}(\.|,)\d{1,2}) *(g|gramme)?.?(par l|\/l|par litre)? *(d\'|de|en)? *(acide?) *(malique|malic)'
      second_malic_regex = '((acide *)?(malic|malique) *(est|était)? *(égal +|= ?|de +|à +)?)(\d{1,3}(\.|,)\d{1,2}|\d{1,3})'
      malic = content.match(malic_regex)
      if malic
        content[malic[0]] = ""
        parameters['malic'] = malic[1].gsub(',','.') # malic is the first capturing group
      elsif content.match(second_malic_regex)
        malic = content.match(second_malic_regex)
        content[malic[0]] = ""
        parameters['malic'] = malic[6].gsub(',','.') # malic is the third capturing group
      else
        parameters['malic'] = nil
      end
      return content, parameters
    end

    def extract_operatoryMode(content, parameters)
      # Extracting operatorymode data
      if content.include?('manuel')
        content['manuel'] = ""
        parameters['operatorymode'] = "manuel"
      elsif content.include?('mécanique')
        content['mécanique'] == ""
        parameters['operatorymode'] = "mecanique"
      else
        parameters['operatorymode'] = nil
      end
      return content, parameters
    end

    def extract_pressing(content, parameters)
      # pressing values can only be added by clicking on a button, and are empty by default
      parameters['pressing'] = nil
      return content, parameters
    end

    def extract_plant_area(content, crops)
      # For each found target
      crops.each do |target|
        # Find the string that matched, ie "Jeunes Plants" when index is [3,4]
        indexes = target[:indexes]
        recon_target = ""
        indexes.each do |index|
          recon_target+= content.split[index]
          if not index == indexes[-1]
            recon_target+=" "
          end
        end
        # Then look for a match of % of target, or (Area) of target
        first_area_regex = /(\d{1,2}) *(%|pour( )?cent(s)?) *(de *(la|l\')?|du|des|sur|à|a|au)? #{recon_target}/
        second_area_regex = /(\d{1,3}|\d{1,3}(\.|,)\d{1,2}) *((hect)?are(s)?) *(de *(la|l\')?|du|des|sur|à|a|au)? #{recon_target}/
        first_area = content.match(first_area_regex)
        if first_area
          # If we found a percentage, append it as the area value
          target[:area] = first_area[1].to_i
        elsif content.match(second_area_regex)
          # If we found an area, convert it in percentage of Total area and append it
          second_area = content.match(second_area_regex)
          area = second_area[1].gsub(',','.').to_f
          if !second_area[3].match(/hect/)
            area = area.to_f/100
          end
          whole_area = Plant.where("id=#{target[:key]}")[0][:reading_cache][:net_surface_area].to_f
          if (100*area/whole_area).to_i <= 100
            target[:area] = (100*area/whole_area).to_i
          else
            target[:area] = 100
          end
        else
          # Otherwise area = 100%
          target[:area] = 100
        end
      end
      return crops
    end

    # Utils functions, that could be used in multiple functionalities

    def find_missing_parameters(parsed)
      # Find what we should ask the user next for an harvest reception
      if parsed[:targets].to_a.empty?
        return "ask_plant", nil, nil
      end
      if parsed[:parameters]['quantity'].nil?
        return "ask_quantity", nil, nil
      end
      if parsed[:destination].to_a.empty?
        return "ask_destination", nil, nil
      end
      # If we have more that one destination, and no quantity specified for at least one, ask for it
      if parsed[:destination].to_a.length > 1 and parsed[:destination].any? {|dest| !dest.key?("quantity")}
        sentence, optional = create_destination_quantity_sentence(parsed)
        return "ask_destination_quantity", sentence, optional
      end
      if parsed[:parameters]["tav"].nil?
        return "ask_tav", nil, nil
      end
      return "save", create_reception_sentence(parsed)
    end

    def concatenate_analysis(parameters, new_parameters)
      # For harvesing receptions, concatenate previous found parameters and new one created for the occasion
      final_parameters = new_parameters
      # Final parameter is the new one, on which we append the quantity value, and all values that were but are not anymore
      final_parameters.each do |key, value|
        if key == "quantiy"
          final_parameters[key] = parameters[key]
        elsif value.nil?
          if not parameters[key].nil?
            final_parameters[key] = parameters[key]
          end
        end
      end
      return final_parameters
    end

    def extract_reception_parameters(content)
      # Extracting all regex parameters for an harvest reception
      parameters = {}
      content, parameters = extract_conflicting_degrees(content, parameters)
      content, parameters = extract_quantity(content, parameters)
      content, parameters = extract_tav(content, parameters)
      content, parameters = extract_temp(content, parameters)
      content, parameters = extract_ph(content, parameters)
      content, parameters = extract_nitrogen(content, parameters)
      content, parameters = extract_sanitarystate(content, parameters)
      content, parameters = extract_malic(content, parameters)
      content, parameters = extrat_h2SO4(content, parameters)
      content, parameters = extract_operatoryMode(content, parameters)
      content, parameters = extract_pressing(content, parameters)
      return content, parameters
    end

    def choose_date(date1, date2)
      # Select a date between two, to find if there's one in those which was manually inputed by the user
      # Date.now is the default value, so if the value returned is more than 15 away from now, we select it
      if (date1.to_datetime - DateTime.now).abs >= 0.010
        return date1
      else
        return date2
      end
    end

    def choose_duration(duration1, duration2)
      # Select a duration between two, to find if there's one in those which was manually inputed by the user
      # Default duration is 60, so select the first one if differents, otherwise the second
      if duration1 != 60
        return duration1
      else
        return duration2
      end
    end

    def unit_to_hectoliter(value, unit)
      if unit == "hl"
        return sprintf('%.3f', value.to_f)
      elsif unit == "kg"
        return sprintf('%.3f', value.to_f/160)
      else
        return sprintf('%.3f', value.to_f/0.160)
      end
    end

    def add_to_recognize_final(saved_hash, list, all_lists)
      # Function that adds elements to a list of recognized items only if no other elements uses the same words to match
      # or if this word has a lower fuzzmatch, #all_lists are all the lists where no overlapping entites can be found
      # If no element inside any of the lists has the same words used to match an element
      if not all_lists.any? {|list1| list1.any? {|recon_element| !(recon_element[:indexes] & saved_hash[:indexes]).empty?}}
        # Then check for eventual duplicates in the list & append if clear
        bln_append, list = key_duplicate_append?(list, saved_hash)
        if bln_append
          list.push(saved_hash)
        end
      # Else if one or multiple elements uses the same words -> if the distance is greater for this hash -> Remove other ones and add this one
      elsif not all_lists.any? {|list1| list1.any? {|recon_element| !(recon_element[:indexes] & saved_hash[:indexes]).empty? and recon_element[:distance] >= saved_hash[:distance]}}
        # Check for duplicates in the list, if clear : -> remove values from all lists whith indexes overlapping and add to our list
        bln_append, list = key_duplicate_append?(list, saved_hash)
        if bln_append
          all_lists.each do |list1| list1.each do |recon_element|
            if  !(recon_element[:indexes] & saved_hash[:indexes]).empty?
              list1.delete(recon_element)
            end
          end
          end
          list.push(saved_hash)
        end
      end
      return list
    end


    def create_words_combo(user_input)
      # Creating all combos of 1 - 4 words following each other to match with entities
      # Working but could be done in a more elegant way !!
      user_inputs_combos = {}
      user_input_words = user_input.split()
      for combo_length in 1..4
        (1..user_input_words.length()).to_a.combination(combo_length).to_a.each do |combo|
          # Only act if the words are following each other
          if combo[-1] - combo[0] <= combo_length - 1
            array_string_to_append = []
            array_indexes = []
            # Create the new string & append it yo all the combos
            combo.each do |combo_index|
              array_indexes.push(combo_index -1)
              array_string_to_append.push(user_input_words[combo_index - 1])
            end
            user_inputs_combos[array_indexes] = array_string_to_append.join(" ")
          end
        end
      end
      return user_inputs_combos
    end

    def compare_elements(string1, string2, indexes, level, key, append_list, saved_hash, rec_list)
        # We check the fuzz distance between two elements, if it's greater than the min_matching_level or the current best distance, this is the new recordman
        distance = @@fuzzloader.getDistance(string1.downcase, string2.downcase)
        if distance > level
          return distance, { :key => key, :name => string2, :indexes => indexes , :distance => distance}, append_list
        end
        return level, saved_hash, rec_list
    end

    def add_input_rate(content, recognized_inputs)
      # This function adds a 1 population quantity to every input that has been found
      # Next step could be to match this type of regex : /{1,3}(g|kg|litre)(d)(de)? *{1}/
      recognized_inputs.each_with_index do |input, index|
        recognized_inputs[index] = {:input => input, :rate => {:value => 1, :unit => "population", "found" => "Nothing"}}
      end
      return recognized_inputs
    end

    def uniq_conc(array1, array2)
      # Concatenate two "recognized items" arrays, by making sure there's not 2 values with the same key
      array2.each do |hash|
        boolean, array1 = key_duplicate_append?(array1, hash)
        if (boolean)
          array1.push(hash)
        end
      end
      return array1
    end

    def key_duplicate_append?(list, saved_hash)
      # Function that checks if we can append saved_hash to list
      # If there's already an element with the same key, it checks for the distance
      # It responds true, or false + the cleaned list on which we can append if true
      if not list.any? {|recon_element| recon_element[:key] == saved_hash[:key]}
        return true, list
      else
        list.each do |recon_element|
          # Otherwise, the recognized_element with the same key : => if greatest distance, we dont append, or we remove it and append the new one
          if recon_element[:key] == saved_hash[:key]
            if recon_element[:distance] >= saved_hash[:distance]
              return false, list
            else
              list.delete(recon_element)
              return true, list
            end
          end
        end
      end
    end
  end
end
