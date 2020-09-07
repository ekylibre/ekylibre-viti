module Duke
  class DukeParsing
    @@fuzzloader = FuzzyStringMatch::JaroWinkler.create( :pure )

    # All functions that are creating sentences for Duke to respond

    def speak_intervention(params)
      # Create validation sentence for InterventionSkill
      I18n.locale = :fra
      sentence = I18n.t("duke.interventions.save_intervention_#{rand(0...3)}")
      sentence += "<br>&#8226 Procédure : #{Procedo::Procedure.find(params[:procedure]).human_name}"
      unless params[:crop_groups].to_a.empty?
        sentence += "<br>&#8226 Groupements : "
        params[:crop_groups].each do |cg|
          sentence += "#{cg[:name]}, "
        end
      end
      unless params[:equipments].to_a.empty?
        sentence += "<br>&#8226 Equipement : "
        params[:equipments].each do |eq|
          sentence += "#{eq[:name]}, "
        end
      end
      unless params[:workers].to_a.empty?
        sentence += "<br>&#8226 Travailleurs : "
        params[:workers].each do |worker|
          sentence += "#{worker[:name]}, "
        end
      end
      unless params[:inputs].to_a.empty?
        sentence += "<br>&#8226 Intrants : "
        params[:inputs].each do |input|
          sentence += "#{input[:input][:name]}, "
        end
      end
      sentence += "<br>&#8226 Date : #{params[:intervention_date].to_datetime.strftime("%d/%m/%Y - %H:%M")}"
      return sentence.gsub(/, <br>&#8226/, "<br>&#8226")
    end

    def speak_harvest_reception(params)
      # Create validation sentence for HarvestReceptionSkill
      I18n.locale = :fra
      sentence = I18n.t("duke.harvest_reception.save_harvest_reception_#{rand(0...2)}")
      unless params[:crop_groups].to_a.empty?
        sentence+= "<br>&#8226 Groupement(s) : "
        params[:crop_groups].each do |crop_group|
          sentence += "#{crop_group[:area].to_s}% #{crop_group[:name]}, "
        end
      end
      unless params[:targets].to_a.empty?
        sentence+= "<br>&#8226 Culture(s) : "
        params[:targets].each do |target|
          sentence += "#{target[:area].to_s}% #{target[:name]}, "
        end
      end
      sentence+= "<br>&#8226 Quantité : #{params[:parameters]['quantity']['rate'].to_s} #{params[:parameters]['quantity']['unit']}"
      sentence+= "<br>&#8226 TAVP : #{params[:parameters]['tav'].to_s} % vol"
      sentence+= "<br>&#8226 Destination : "
      params[:destination].each do |destination|
        sentence+= destination[:name]
        sentence+= " (#{destination[:quantity].to_s} hl), " if destination.key?('quantity')
      end
      sentence+= "<br>&#8226 Date : #{params[:intervention_date].to_datetime.strftime("%d/%m/%Y - %H:%M")}"
      unless params[:parameters]['temperature'].nil?
        sentence+= "<br>&#8226 Température : #{params[:parameters]['temperature']} °C"
      end
      unless params[:parameters]['sanitarystate'].nil?
        sentence+= "<br>&#8226 État sanitaire spécifié"
      end
      unless params[:parameters]['ph'].nil?
        sentence+= "<br>&#8226 pH : #{params[:parameters]['ph']}"
      end
      unless params[:parameters]['h2so4'].nil?
        sentence+= "<br>&#8226 Acidité totale : #{params[:parameters]['h2so4']} g H2SO4/L"
      end
      unless params[:parameters]['malic'].nil?
        sentence+= "<br>&#8226 Acide Malique : #{params[:parameters]['malic']} g/L"
      end
      unless params[:parameters]['amino_nitrogen'].nil?
        sentence+= "<br>&#8226 Azote aminée : #{params[:parameters]['amino_nitrogen']} mg/L"
      end
      unless params[:parameters]['ammoniacal_nitrogen'].nil?
        sentence+= "<br>&#8226 Azote ammoniacal : #{params[:parameters]['ammoniacal_nitrogen']} mg/L"
      end
      unless params[:parameters]['assimilated_nitrogen'].nil?
        sentence+= "<br>&#8226 Azote assimilé : #{params[:parameters]['assimilated_nitrogen']} mg/L"
      end
      unless params[:parameters]['pressing'].nil?
        sentence+= "<br>&#8226 Pressurage spécifié"
      end
      unless params[:parameters]['pressing_tavp'].nil?
        sentence+= "<br>&#8226 TAVP jus de presse : #{params[:parameters]['pressing_tavp'].to_s} % vol "
      end
      unless params[:parameters]['complementary'].nil?
        if params[:parameters]['complementary'].key?('ComplementaryDecantation')
          sentence+= "<br>&#8226 Temps de décantation : #{params[:parameters]['complementary']['ComplementaryDecantation'].delete("^0-9")} mins"
        end
        if params[:parameters]['complementary'].key?('ComplementaryTrailer')
          sentence+= "<br>&#8226 Transporteur : #{params[:parameters]['complementary']['ComplementaryTrailer']}"
        end
        if params[:parameters]['complementary'].key?('ComplementaryTime')
          sentence+= "<br>&#8226 Durée de transport : #{params[:parameters]['complementary']['ComplementaryTime'].delete("^0-9")} mins"
        end
        if params[:parameters]['complementary'].key?('ComplementaryDock')
          sentence+= "<br>&#8226 Quai de réception : #{params[:parameters]['complementary']['ComplementaryDock']}"
        end
        if params[:parameters]['complementary'].key?('ComplementaryNature')
          sentence+= "<br>&#8226 Type de vendange : #{I18n.t('labels.'+params[:parameters]['complementary']['ComplementaryNature'])}"
        end
        if params[:parameters]['complementary'].key?('ComplementaryLastLoad')
          sentence+= "<br>&#8226 Dernier chargement"
        end
      end
      return sentence.gsub(/, <br>&#8226/, "<br>&#8226")
    end

    def speak_destination_hl(params)
      # Creates "How much hectoliters in Cuve 1 ?"
      # Return the sentence, and the index of the destination inside params[:destination] to transfer as an optional value to IBM
      I18n.locale = :fra
      sentence = I18n.t("duke.harvest_reception.how_much_to_#{rand(0...2)}")
      params[:destination].each_with_index do |cuve, index|
        unless cuve.key?("quantity")
          sentence += cuve[:name]
          return sentence, index
        end
      end
    end

    def create_analysis_attributes(parsed)
      attributes =    {"0"=>{"_destroy"=>"false", "indicator_name"=>"estimated_harvest_alcoholic_volumetric_concentration", "measure_value_value"=> parsed[:parameters]['tav'], "measure_value_unit"=>"volume_percent"}}
      attributes[1] = {"_destroy"=>"false", "indicator_name"=>"potential_hydrogen", "decimal_value"=> parsed[:parameters]['ph'] } unless parsed[:parameters]['ph'].nil?
      attributes[2] = {"_destroy"=>"false", "indicator_name"=>"temperature", "measure_value_value"=> parsed[:parameters]['temperature'], "measure_value_unit"=>"celsius"} unless parsed[:parameters]['temperature'].nil?
      attributes[3] = {"_destroy"=>"false", "indicator_name"=>"assimilated_nitrogen_concentration", "measure_value_value"=> parsed[:parameters]['assimilated_nitrogen'], "measure_value_unit"=>"milligram_per_liter"} unless parsed[:parameters]['assimilated_nitrogen'].nil?
      attributes[4] = {"_destroy"=>"false", "indicator_name"=>"amino_nitrogen_concentration", "measure_value_value"=> parsed[:parameters]['amino_nitrogen'], "measure_value_unit"=>"milligram_per_liter"} unless parsed[:parameters]['amino_nitrogen'].nil?
      attributes[5] = {"_destroy"=>"false", "indicator_name"=>"ammoniacal_nitrogen_concentration", "measure_value_value"=> parsed[:parameters]['ammoniacal_nitrogen'], "measure_value_unit"=>"milligram_per_liter"} unless parsed[:parameters]['ammoniacal_nitrogen'].nil?
      attributes[6] = {"_destroy"=>"false", "indicator_name"=>"total_acid_concentration", "measure_value_value"=>parsed[:parameters]['h2so4'], "measure_value_unit"=>"gram_per_liter"} unless parsed[:parameters]['h2so4'].nil?
      attributes[7] = {"_destroy"=>"false", "indicator_name"=>"malic_acid_concentration", "measure_value_value"=>parsed[:parameters]['malic'], "measure_value_unit"=>"gram_per_liter"} unless parsed[:parameters]['malic'].nil?
      attributes[8] = {"_destroy"=>"false", "indicator_name"=>"sanitary_vine_harvesting_state", "string_value"=> parsed[:parameters]['sanitarystate']} unless parsed[:parameters]['sanitarystate'].nil?
      attributes[9] = {"measure_value_unit" =>"volume_percent","indicator_name" => "estimated_pressed_harvest_alcoholic_volumetric_concentration", "measure_value_value" => parsed[:parameters]['pressing_tavp']} unless parsed[:parameters]['pressing_tavp'].nil?
      return attributes
    end

    def create_incoming_harvest_attr(dic, parsed)
      I18n.locale = :fra
      unless parsed[:parameters]['pressing'].nil?
        dic[:pressing_schedule] = parsed[:parameters]['pressing']['program']
        dic[:pressing_started_at] = parsed[:parameters]['pressing']['hour'].to_datetime.strftime("%H:%M")
      end
      unless parsed[:parameters]['complementary'].nil?
        if parsed[:parameters]['complementary'].key?('ComplementaryDecantation')
          dic[:sedimentation_duration] = parsed[:parameters]['complementary']['ComplementaryDecantation'].delete("^0-9")
        end
        if parsed[:parameters]['complementary'].key?('ComplementaryTrailer')
          dic[:vehicle_trailer] = parsed[:parameters]['complementary']['ComplementaryTrailer']
        end
        if parsed[:parameters]['complementary'].key?('ComplementaryTime')
          dic[:harvest_transportation_duration] = parsed[:parameters]['complementary']['ComplementaryTime'].delete("^0-9")
        end
        if parsed[:parameters]['complementary'].key?('ComplementaryDock')
          dic[:harvest_dock] = parsed[:parameters]['complementary']['ComplementaryDock']
        end
        if parsed[:parameters]['complementary'].key?('ComplementaryNature')
          dic[:harvest_nature] = parsed[:parameters]['complementary']['ComplementaryNature']
        end
        if parsed[:parameters]['complementary'].key?('ComplementaryLastLoad')
          dic[:last_load] = "true"
        end
      end
      return dic
    end
    # Extracting functions, regex / including

    def extract_duration_fr(content)
        #Function that finds the duration of the intervention & converts this value in minutes using regexes to have it stored into Ekylibre
        delta_in_mins = 0
        regex = '\d+\s(\w*minute\w*|mins)'
        regex2 = '(de|pendant|durée) *(\d)\s?(heures|h|heure)\s?(\d\d)'
        regex3 = '(de|pendant|durée) *(\d)\s?(h\b|h\s|heure)'
        if content.include? "trois quarts d'heure"
          content["trois quart d'heure"] = ""
          return 45, content.strip.gsub(/\s+/, " ")
        end
        if content.include? "quart d'heure"
          content["quart d'heure"] = ""
          return 15, content.strip.gsub(/\s+/, " ")
        end
        if content.include? "demi heure"
          content["demi heure"] = ""
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
      time, content = extract_hour(content)
      # Search for keywords
      if content.include? "avant-hier"
        content["avant-hier"] = ""
        d = Date.yesterday.prev_day
      elsif content.include? "hier"
        content["hier"] = ""
        d = Date.yesterday
      elsif content.include? "demain"
        content["demain"] = ""
        d = Date.tomorrow
      else
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
      quantity_regex = '(\d{1,5}(\.|,)\d{1,2}|\d{1,5}) *(kilo|kg|hecto|expo|texto|hl|t\b|tonne)'
      quantity = content.match(quantity_regex)
      if quantity
        content[quantity[0]] = ""
        if quantity[3].match('(kilo|kg)')
          unit = "kg"
        elsif quantity[3].match('(hecto|hl|texto|expo)')
          unit = "hl"
        else
          unit = "t"
        end
        parameters['quantity'] = {"rate" => quantity[1].gsub(',','.').to_f, "unit" => unit} # rate is the first capturing group
      else
        parameters['quantity'] = nil
      end
      return content, parameters
    end

    def extract_conflicting_degrees(content, parameters)
      # Conflicts between TAV "degré" and temperature "degré", so we need to check first for explicit values
      second_tav_regex = '(degré d\'alcool|alcool|degré|tavp|tav|avp|t svp|pourcentage|t avait) *(jus de presse)? *(est|était)? *(égal +(a *|à *)?|= *|de *|à *)?(\d{1,2}(\.|,)\d{1,2}|\d{1,2}) *(degré)?'
      second_temp_regex = '(température|temp) *(est|était)? *(égal *|= *|de *|à *)?(\d{1,2}(\.|,)\d{1,2}|\d{1,2}) *(degré)?'
      tav = content.match(second_tav_regex)
      if tav
        content[tav[0]] = ""
        parameters['tav'] = tav[6].gsub(',','.') # rate is the fifth capturing group
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
      tav_regex = '(\d{1,2}|\d{1,2}(\.|,)\d{1,2}) ((degré(s)?|°|%)|(de|en|d\')? *(tavp|tav|(t)? *avp|(t)? *svp|t avait|thé avait|thé à l\'épée|alcool|(entea|mta) *vp))'
      tav = content.match(tav_regex)
      unless parameters.key?('tav')
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
      temp_regex = '(\d{1,2}|\d{1,2}(\.|,)\d{1,2}) +(degré|°)'
      temp = content.match(temp_regex)
      unless parameters.key?('temperature')
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
      second_ph = content.match(second_ph_regex)
      if ph
        content[ph[0]] = ""
        parameters['ph'] = ph[1].gsub(',','.') # ph is the first capturing group
      elsif second_ph
        content[second_ph[0]] = ""
        parameters['ph'] = second_ph[6].gsub(',','.') # ph is the third capturing group
      else
        parameters['ph'] = nil
      end
      return content, parameters
    end

    def extract_amino_nitrogen(content, parameters)
      # Extracting nitrogen data
      nitrogen_regex = '(\d{1,3}|\d{1,3}(\.|,)\d{1,2}) +(mg|milligramme)?.?(par l|\/l|par litre)? ?+(d\'|de|en)? *azote aminé'
      second_nitrogen_regex = '(azote aminé *(est|était)? *(égal +|= ?|de +)?(à)? *)(\d{1,3}(\.|,)\d{1,2}|\d{1,3})'
      nitrogen = content.match(nitrogen_regex)
      second_nitrogen = content.match(second_nitrogen_regex)
      if nitrogen
        content[nitrogen[0]] = ""
        parameters['amino_nitrogen'] = nitrogen[1].gsub(',','.') # nitrogen is the first capturing group
      elsif second_nitrogen
        content[second_nitrogen[0]] = ""
        parameters['amino_nitrogen'] = second_nitrogen[5].gsub(',','.') # nitrogen is the seventh capturing group
      else
        parameters['amino_nitrogen'] = nil
      end
      return content, parameters
    end

    def extract_ammoniacal_nitrogen(content, parameters)
      # Extracting nitrogen data
      nitrogen_regex = '(\d{1,3}|\d{1,3}(\.|,)\d{1,2}) +(mg|milligramme)?.?(par l|\/l|par litre)? ?+(d\'|de|en)? *azote ammonia'
      second_nitrogen_regex = '(azote (ammoniacal|ammoniaque) *(est|était)? *(égal +|= ?|de +)?(à)? *)(\d{1,3}(\.|,)\d{1,2}|\d{1,3})'
      nitrogen = content.match(nitrogen_regex)
      second_nitrogen = content.match(second_nitrogen_regex)
      if nitrogen
        content[nitrogen[0]] = ""
        parameters['ammoniacal_nitrogen'] = nitrogen[1].gsub(',','.') # nitrogen is the first capturing group
      elsif second_nitrogen
        content[second_nitrogen[0]] = ""
        parameters['ammoniacal_nitrogen'] = second_nitrogen[6].gsub(',','.') # nitrogen is the seventh capturing group
      else
        parameters['ammoniacal_nitrogen'] = nil
      end
      return content, parameters
    end

    def extract_assimilated_nitrogen(content, parameters)
      # Extracting nitrogen data
      nitrogen_regex = '(\d{1,3}|\d{1,3}(\.|,)\d{1,2}) +(mg|milligramme)?.?(par l|\/l|par litre)? ?+(d\'|de|en)? ?+(azote *(assimilable)?|sel d\'ammonium|substance(s)? azotée)'
      second_nitrogen_regex = '((azote *(assimilable)?|sel d\'ammonium|substance azotée) *(est|était)? *(égal +|= ?|de +)?(à)? *)(\d{1,3}(\.|,)\d{1,2}|\d{1,3})'
      nitrogen = content.match(nitrogen_regex)
      second_nitrogen = content.match(second_nitrogen_regex)
      if nitrogen
        content[nitrogen[0]] = ""
        parameters['assimilated_nitrogen'] = nitrogen[1].gsub(',','.') # nitrogen is the first capturing group
      elsif second_nitrogen
        content[second_nitrogen[0]] = ""
        parameters['assimilated_nitrogen'] = second_nitrogen[7].gsub(',','.') # nitrogen is the seventh capturing group
      else
        parameters['assimilated_nitrogen'] = nil
      end
      return content, parameters
    end

    def extract_sanitarystate(content, parameters)
      # Extracting sanitary state data
      sanitary_regex = '(état sanitaire) *(.*?)(destination|tav|\d{1,3} *(kg|hecto|kilo|hl|tonne)|cuve|degré|température|pourcentage|alcool|ph|péage|azote|acidité|malique|manuel|mécanique|hectare|$)'
      sanitary_match = content.match(sanitary_regex)
      sanitarystate = ""
      if sanitary_match
        sanitarystate += sanitary_match[2]
        content[sanitary_match[1]] = ""
        content[sanitary_match[2]] = ""
      end
      if content.include? "sain " || content.include?("sein")
        sanitarystate += "sain "
      end
      if content.include?("correct")
        content["correct"] = ""
        sanitarystate += "correct "
      end
      if content.include?("normal")
        content["normal"] = ""
        sanitarystate += "normal "
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
      second_h2so4 = content.match(second_h2so4_regex)
      if h2so4
        content[h2so4[0]] = ""
        parameters['h2so4'] = h2so4[1].gsub(',','.') # h2so4 is the first capturing group
      elsif second_h2so4
        content[second_h2so4[0]] = ""
        parameters['h2so4'] = second_h2so4[5].gsub(',','.') # h2so4 is the third capturing group
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
      second_malic = content.match(second_malic_regex)
      if malic
        content[malic[0]] = ""
        parameters['malic'] = malic[1].gsub(',','.') # malic is the first capturing group
      elsif second_malic
        content[second_malic[0]] = ""
        parameters['malic'] = second_malic[6].gsub(',','.') # malic is the third capturing group
      else
        parameters['malic'] = nil
      end
      return content, parameters
    end

    def extract_decantation_time(content)
      decantation_regex = /((pendant|à|(temps de )*décantation (de)?|duran.) *)([5-9]|1[0-9]|2[03]) *(heure(s)?|h|:) *([0-5]?[0-9])?/
      decantation = content.match(decantation_regex)
      decantation_time = 0
      if decantation
        content[decantation[0]] = ""
        decantation_time = decantation[5].to_i * 60
        unless decantation[8].nil?
          decantation_time += decantation[8].to_i
        end
      end
      return decantation_time, content
    end

    def extract_pressing(content, parameters)
      # pressing values can only be added by clicking on a button, and are empty by default
      parameters['pressing'] = nil
      return content, parameters
    end

    def extract_pressing_tavp(content, parameters)
      # pressing values can only be added by clicking on a button, and are empty by default
      parameters['pressing_tavp'] = nil
      return content, parameters
    end

    def extract_complementary(content, parameters)
      # pressing values can only be added by clicking on a button, and are empty by default
      parameters['complementary'] = nil
      return content, parameters
    end

    def extract_plant_area(content, targets, crop_groups)
      [targets, crop_groups].each do |crops|
        crops.each do |target|
          # Find the string that matched, ie "Jeunes Plants" when index is [3,4], then look for it in regex
          recon_target = content.split()[target[:indexes][0]..target[:indexes][-1]].join(" ")
          first_area_regex = /(\d{1,2}) *(%|pour( )?cent(s)?) *(de *(la|l\')?|du|des|sur|à|a|au)? #{recon_target}/
          second_area_regex = /(\d{1,3}|\d{1,3}(\.|,)\d{1,2}) *((hect)?are(s)?) *(de *(la|l\')?|du|des|sur|à|a|au)? #{recon_target}/
          first_area = content.match(first_area_regex)
          second_area = content.match(second_area_regex)
          # If we found a percentage, append it as the area value
          if first_area
            target[:area] = first_area[1].to_i
          # If we found an area, convert it in percentage of Total area and append it
          elsif second_area && !Plant.find_by(id: target[:key]).nil?
            target[:area] = 100
            if second_area[3].match(/hect/)
              area = second_area[1].gsub(',','.').to_f
            else
              area = second_area[1].gsub(',','.').to_f/100
            end
            whole_area = Plant.find_by(id: target[:key])&.net_surface_area&.to_f
            unless whole_area.zero?
              target[:area] = [(100*area/whole_area).to_i, 100].min
            end
          else
            # Otherwise Area = 100%
            target[:area] = 100
          end
        end
      end
      return targets, crop_groups
    end

    # Utils functions, that could be used in multiple functionalities

    def find_missing_parameters(parsed)
      # Find what we should ask the user next for an harvest reception
      unless parsed[:ambiguities].to_a.empty?
        return "ask_ambiguity", nil, parsed[:ambiguities][0]
      end
      if parsed[:targets].to_a.empty? && parsed[:crop_groups].to_a.empty?
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
        sentence, optional = speak_destination_hl(parsed)
        return "ask_destination_quantity", sentence, optional
      end
      if parsed[:parameters]["tav"].nil?
        return "ask_tav", nil, nil
      end
      return "save", speak_harvest_reception(parsed)
    end

    def concatenate_analysis(parameters, new_parameters)
      # For harvesing receptions, concatenate previous found parameters and new one given by the user
      final_parameters =  new_parameters.dup.map(&:dup).to_h
      new_parameters.each do |key, value|
        if ['key','tav'].include?(key)
          final_parameters[key] = parameters[key]
        elsif value.nil?
          unless parameters[key].nil?
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
      content, parameters = extract_amino_nitrogen(content, parameters)
      content, parameters = extract_ammoniacal_nitrogen(content, parameters)
      content, parameters = extract_assimilated_nitrogen(content, parameters)
      content, parameters = extract_sanitarystate(content, parameters)
      content, parameters = extract_malic(content, parameters)
      content, parameters = extrat_h2SO4(content, parameters)
      content, parameters = extract_pressing(content, parameters)
      content, parameters = extract_complementary(content, parameters)
      content, parameters = extract_pressing_tavp(content,parameters)
      return content, parameters
    end

    def choose_date(date1, date2)
      #Select a date between two, to find if there's one in those which was manually inputed by the user
      #Date.now is the default value, so if the value returned is more than 15 away from now, we select it
      if (date1.to_datetime - DateTime.now).abs >= 0.010
        return date1
      else
        return date2
      end
    end

    def choose_duration(duration1, duration2)
      #Select a duration between two, to find if there's one in those which was manually inputed by the user
      #Default duration is 60, so select the first one if differents, otherwise the second
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
        return sprintf('%.3f', value.to_f/130)
      else
        return sprintf('%.3f', value.to_f/0.130)
      end
    end

    def add_to_recognize_final(saved_hash, list, all_lists, content)
      #Function that adds elements to a list of recognized items only if no other elements uses the same words to match or if this word has a lower fuzzmatch
      #If no element inside any of the lists has the same words used to match an element (overlapping indexes)
      if not all_lists.any? {|aList| aList.any? {|recon_element| !(recon_element[:indexes] & saved_hash[:indexes]).empty?}}
        hasDuplicate, list = key_duplicate?(list, saved_hash)
        unless hasDuplicate
          list.push(saved_hash)
        end
      # Else if one or multiple elements uses the same words -> if the distance is greater for this hash -> Remove other ones and add this one
    elsif not all_lists.any? {|aList| aList.any? {|recon_element| !(recon_element[:indexes] & saved_hash[:indexes]).empty? and !better_corrected_distance?(saved_hash, recon_element, content)}}
        # Check for duplicates in the list, if clear : -> remove value from any list with indexes overlapping and add current match to our list
        hasDuplicate, list = key_duplicate?(list, saved_hash)
        unless hasDuplicate
          list_where_removing = all_lists.find{ |aList| aList.any? {|recon_element| !(recon_element[:indexes] & saved_hash[:indexes]).empty?}}
          unless list_where_removing.nil?
            item_to_remove = list_where_removing.find {|hash|!(hash[:indexes] & saved_hash[:indexes]).empty?}
            list_where_removing.delete(item_to_remove)
          end
          list.push(saved_hash)
        end
      end
      return list
    end

    def create_words_combo(user_input)
      # "Je suis ton " becomes { [0] => "Je", [0,1] => "Je suis", [0,1,2] => "Je suis ton", [1] => "suis", [1,2] => "suis ton", [2] => "ton"}
      words_combos = {}
      (0..user_input.split().length).to_a.combination(2).to_a.each do |index_combo|
        if index_combo[0] + 4 >= index_combo[1]
          words_combos[(index_combo[0]..index_combo[1]-1).to_a] = user_input.split()[index_combo[0]..index_combo[1]-1].join(" ")
        end
      end
      return words_combos
    end

    def compare_elements(string1, string2, indexes, level, key, append_list, saved_hash, rec_list)
        # We check the fuzz distance between two elements, if it's greater than the min_matching_level or the current best distance, this is the new recordman
        distance = @@fuzzloader.getDistance(string1, clear_string(string2))
        if distance > level
          return distance, { :key => key, :name => string2, :indexes => indexes , :distance => distance}, append_list
        end
        return level, saved_hash, rec_list
    end

    def better_corrected_distance?(a,b, content)
      # When user says "Bouleytreau Verrier", should we match "Bouleytreau" or "Bouleytreau-Verrier" ? Correcting distance with length of item found
      if a[:key] == b[:key]
        return (true if a[:distance] >= b[:distance]) || false
      else
        len_a = content.split()[a[:indexes][0]..a[:indexes][-1]].join(" ").split("").length
        len_b = content.split()[b[:indexes][0]..b[:indexes][-1]].join(" ").split("").length
        aDist = a[:distance].to_f * Math.exp((len_a - len_b)/70.0)
        aDist *= Math.exp(((len_b - b[:name].split("").length).abs()-(len_a -a[:name].split("").length).abs())/100.0)
        if aDist > b[:distance]
          return true
        else
          return false
        end
      end
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
      new_array = array1.dup.map(&:dup)
      array2.each do |hash|
        hasDuplicate, new_array = key_duplicate?(new_array, hash)
        unless hasDuplicate
          new_array.push(hash)
        end
      end
      return new_array
    end

    def find_ambiguity(parsed, content)
      ambiguities = []
      parsed.each do |key, reco|
        if [:targets, :destination, :crop_groups].include?(key)
          reco.each do |anItem|
            ambig = []
            anItem_name = content.split()[anItem[:indexes][0]..anItem[:indexes][-1]].join(" ")
            if key == :targets
              iterator = Plant.availables(at: parsed[:intervention_date])
            elsif key == :destination
              iterator = Matter.availables(at: parsed[:intervention_date]).where("variety='tank'")
            elsif key == :crop_groups
              iterator = CropGroup.all.where("target = 'plant'")
            end
            iterator.each do |product|
              if anItem[:key] != product[:id] and (anItem[:distance] - @@fuzzloader.getDistance(clear_string(product[:name]), clear_string(anItem_name))).between?(0,0.02)
                ambig.push({"key" => product[:id].to_s, "name" => product[:name]})
              end
            end
            unless ambig.empty?
              ambig.push({"key" => anItem[:key].to_s, "name" => anItem[:name]})
              ambig.push({"key" => "inSentenceName", "name" => anItem_name})
              # Only save ambiguities between max 7 elements
              ambiguities.push(ambig.drop((ambig.length - 9 if ambig.length - 9 > 0 ) || 0))
            end
          end
        end
      end
      return ambiguities
    end

    def clear_string(fstr)
      useless_dic = [/\bnum(e|é)ro\b/, /n ?°/, /(#|-|_|\/|\\)/]
      useless_dic.each do |rgx|
        fstr = fstr.gsub(rgx, "")
      end
      return fstr.gsub(/\s+/, " ").downcase
    end

    def key_duplicate?(list, saved_hash)
      # Is there a duplicate in the list ? + List we want to keep using. List Mutation allows us to persist modification
      # -> No Duplicate : no + current list, Duplicate -> Distance(+/-)=No/Yes + Current list (with/without duplicate)
      if not list.any? {|recon_element| recon_element[:key] == saved_hash[:key]}
        return false, list
      elsif not list.any? {|recon_element| recon_element[:key] == saved_hash[:key] and saved_hash[:distance] >= recon_element[:distance] }
        return true, list
      else
        item_to_remove = list.find {|hash| hash[:key] == saved_hash[:key]}
        list.delete(item_to_remove)
        return false, list
      end
    end
  end
end
