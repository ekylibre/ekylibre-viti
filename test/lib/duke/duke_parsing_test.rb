require 'test_helper'

module Duke
  class DukeParsingTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
    DukeParsing = Duke::DukeParsing.new
    test 'create words combos' do
      # Should return exactly 30 combos of words
      _(DukeParsing.create_words_combo("This is a sentence written to test the function").length).must_equal 30 ,"Not enough combos of words are created"
      # Must match the combos given
      _(DukeParsing.create_words_combo("this is a sentence")).must_equal  ({[0]=>"this",
                                                                           [1]=>"is",
                                                                           [2]=>"a",
                                                                           [3]=>"sentence",
                                                                           [0, 1]=>"this is",
                                                                           [1, 2]=>"is a",
                                                                           [2, 3]=>"a sentence",
                                                                           [0, 1, 2]=>"this is a",
                                                                           [1, 2, 3]=>"is a sentence",
                                                                           [0, 1, 2, 3]=>"this is a sentence"}),
                                                                           "Combos are not created correctly"
    end

    test 'Check for duplicates' do
      saved_hash = {:key=>6, :name=>"Plantations nouvelles 2019", :indexes=>[7, 8], :distance=>0.95}
      saved_hash_lower = {:key=>4, :name=>"Jeunes plants", :indexes=>[4, 5], :distance=>0.94}
      saved_hash_higher = {:key=>4, :name=>"Jeunes plants", :indexes=>[4, 5], :distance=>0.98}
      target_list = [{:key=>4, :name=>"Jeunes plants", :indexes=>[3, 4], :distance=>0.97}]
      # No duplicate, should return True & previous list
      assert_equal(DukeParsing.key_duplicate_append?(target_list, saved_hash), [true, target_list], "Finds a duplicate when not present")
      # Duplicate with higher distance, should return False & previous list
      assert_equal(DukeParsing.key_duplicate_append?(target_list, saved_hash_lower), [false, target_list], "Duplicate with higher distance not found")
      # Duplicate with lower distance, should return True & previous list without the duplicate
      assert_equal(DukeParsing.key_duplicate_append?(target_list, saved_hash_higher), [true, []], "Duplicate with lower distance not found")
    end

    test '(not)? adding a recognized element to its list' do
      saved_hash_no_index = {:key=>2, :name=>"Bouleytreau-Verrier", :indexes=>[3, 4, 5, 6], :distance=>0.95}
      saved_hash_yes_index = {:key=>2, :name=>"Bouleytreau-Verrier", :indexes=>[3, 4, 5, 6], :distance=>0.98}
      saved_hash_no_other_list = {:key=>2, :name=>"Bouleytreau-Verrier", :indexes=>[10, 11], :distance=>0.98}
      saved_hash_yes_other_list = {:key=>2, :name=>"Bouleytreau-Verrier", :indexes=>[7, 8], :distance=>0.99}
      saved_hash_yes = {:key=>6, :name=>"Plantations nouvelles 2019", :indexes=>[5, 6], :distance=>0.95}
      target_list = [{:key=>4, :name=>"Jeunes plants", :indexes=>[3, 4], :distance=>0.97}]
      all_lists = [[{:key=>8, :name=>"Massey-Fergusson 140", :indexes=>[7, 8], :distance=>0.92}],
                   [{:key=>74, :name=>"Frédéric", :indexes=>[10], :distance=>1.0}],
                   [],
                   target_list]
      # No changes to the list, overlapping indexes and greater distance for the previous item
      _(DukeParsing.add_to_recognize_final(saved_hash_no_index, target_list, all_lists)).must_equal target_list, "Item in the same list with overlapping indexes"
      # Changes to the list, overlapping indexes and greater distance
      _(DukeParsing.add_to_recognize_final(saved_hash_yes_index, target_list, all_lists)).must_equal  [saved_hash_yes_index], "Distance is greater for the new item"
      # No changes to the list, item in another list but its distance is greater
      _(DukeParsing.add_to_recognize_final(saved_hash_no_other_list, target_list, all_lists)).must_equal target_list, "Item in another list with same indexes"
      # Changes to the list, item in another list with overlapping indexes and a smaller distance
      _(DukeParsing.add_to_recognize_final(saved_hash_yes_other_list, target_list, all_lists)).must_equal [saved_hash_yes_other_list], "Item in another list with same indexes"
      # Changes to the list, basic case, nothing should interrupt
      _(DukeParsing.add_to_recognize_final(saved_hash_yes, target_list, all_lists)).must_equal [target_list[0], saved_hash_yes], "Basic case not working"
    end

    test 'concatenate two recognized elements arrays' do
      basic_array = [{:key=>4, :name=>"Jeunes plants", :indexes=>[3, 4], :distance=>0.97}]
      new_array_1 = [{:key=>4, :name=>"Jeunes plants", :indexes=>[17, 18], :distance=>0.96}]
      new_array_2 = [{:key=>2, :name=>"Bouleytreau-Verrier", :indexes=>[11, 12], :distance=>0.95}]
      new_array_3 = [{:key=>2, :name=>"Bouleytreau-Verrier", :indexes=>[11, 12], :distance=>0.95},
                     {:key=>4, :name=>"Jeunes plants", :indexes=>[17, 18], :distance=>0.96}]
      # Returns the previous array - trying to add a duplicate
      assert_equal(DukeParsing.uniq_conc(basic_array, new_array_1), basic_array, "Shouldn't add a duplicate to the concatenated array")
      # Returns the concatenations of the two arrays - no duplicate
      assert_equal(DukeParsing.uniq_conc(basic_array, new_array_2), [basic_array[0], new_array_2[0]], "Can't add element to new array")
      # Returns the concatenations of the two arrays, without the duplicate
      assert_equal(DukeParsing.uniq_conc(basic_array, new_array_3), [basic_array[0], new_array_3[0]], "Can't add correct element to new array")
    end

    test 'Compare two strings' do
      target_list = []
      workers_list = []
      # When there's a match, it should return : - distance , hash = {key, name, indexes, distance}, list_to_append
      assert_equal(DukeParsing.compare_elements("bouley trop", "Bouleytreau", [1,2,3], 0.90, "item-id", target_list, nil, nil),
                  [0.9173553719008265, { :key => "item-id", :name => "Bouleytreau", :indexes => [1,2,3] , :distance => 0.9173553719008265}, target_list],
                  "Matching between a combo & an item did not return correctly")
      # When there's no match, it should return : - previous_distance , previous_best_hash, previous_list_to_append
      assert_equal(DukeParsing.compare_elements("blatte trop", "Bouleytreau", [1,2,3], 0.90, "item-id", target_list, nil, nil),
                  [0.90, nil, nil],
                  "Not matching elements did not return correctly when comparing")
    end

    test 'concatenate two parameters arrays' do
      old = {"tav"=>"12.3", "temperature"=>"18", "quantity"=>{"rate"=>200, "unit"=>"kg"}, "ph"=>"12", "nitrogen"=>"12.5", "sanitarystate"=>nil, "malic"=>nil, "h2so4"=>"4", "operatorymode"=>"manual", "pressing"=>nil}
      new = {"tav"=>"14.5", "quantity"=>nil, "temperature"=>nil, "ph"=>nil, "nitrogen"=>nil, "sanitarystate"=>"sain botrytis ", "malic"=>"12", "h2so4"=>nil, "operatorymode"=>nil, "pressing"=>nil}
      assert_equal(DukeParsing.concatenate_analysis(old, new),
                                                   {"tav"=>"14.5",
                                                    "quantity"=>{"rate"=>200, "unit"=>"kg"},
                                                    "temperature"=>"18",
                                                    "ph"=>"12",
                                                    "nitrogen"=>"12.5",
                                                    "sanitarystate"=>"sain botrytis ",
                                                    "malic"=>"12",
                                                    "h2so4"=>"4",
                                                    "operatorymode"=>"manual",
                                                    "pressing"=>nil},
                                                    "Can't concatenate two analysis")
    end

    test 'regex extraction' do
      assert_equal(DukeParsing.extract_quantity("120 kg", {})[1]['quantity'],
                                               {"rate" => 120, "unit" => "kg"},
                                                "Basic Quantity regex failed")
      assert_equal(DukeParsing.extract_quantity("12,4 hectos", {})[1]['quantity'],
                                               {"rate" => 12.4, "unit" => "hl"},
                                                "Coma Quantity regex failed")
      assert_equal(DukeParsing.extract_quantity("3.8 tonnes", {})[1]['quantity'],
                                               {"rate" => 3.8, "unit" => "tonne"},
                                                "Dot Quantity regex failed")
      assert_equal(DukeParsing.extract_conflicting_degrees("température de 17,4 degrés", {})[1]['temperature'],
                                                            "17.4",
                                                           "Conflicting degrees regex failed")
      assert_equal(DukeParsing.extract_conflicting_degrees("degré d'alcool de 12,4 degrés", {})[1]['tav'],
                                                           "12.4",
                                                           "Conflicting degrees regex failed")
      assert_equal(DukeParsing.extract_tav("12,3 de tavp", {})[1]['tav'],
                                           "12.3",
                                           "TAVP regex failed")
      assert_equal(DukeParsing.extract_tav("12,5 degrés d'alcool", {})[1]['tav'],
                                           "12.5",
                                           "TAVP regex failed")
      assert_equal(DukeParsing.extract_temp("18 °", {})[1]['temperature'],
                                            "18",
                                            "Temperature regex failed")
      assert_equal(DukeParsing.extract_temp("19 degrés", {})[1]['temperature'],
                                            "19",
                                            "TAVP regex failed")
      assert_equal(DukeParsing.extract_ph("péage de 3,7", {})[1]['ph'],
                                          "3.7",
                                          "pH regex failed")
      assert_equal(DukeParsing.extract_ph("3.9 de ph", {})[1]['ph'],
                                          "3.9",
                                          "pH regex failed")
      assert_equal(DukeParsing.extract_nitrogen("12,4 milligrammes de sel d'ammonium", {})[1]['nitrogen'],
                                                "12.4",
                                                "nitrogen regex failed")
      assert_equal(DukeParsing.extract_nitrogen("azote était égal à 42", {})[1]['nitrogen'],
                                                "42",
                                                "nitrogen regex failed")
      assert_equal(DukeParsing.extract_sanitarystate("sain et botrytis", {})[1]['sanitarystate'],
                                                     "sain botrytis ",
                                                     "SanitaryState regex failed")
      assert_equal(DukeParsing.extrat_h2SO4("8,2 grammes par litre d'acide", {})[1]['h2so4'],
                                            "8.2",
                                            "H2So4 regex failed")
      assert_equal(DukeParsing.extrat_h2SO4("acidité égale à 3 grammes", {})[1]['h2so4'],
                                            "3",
                                            "H2So4 regex failed")
      assert_equal(DukeParsing.extract_malic("12.5 grammes d'acide malique", {})[1]['malic'],
                                             "12.5",
                                             "Malic regex failed")
      assert_equal(DukeParsing.extract_malic("Acide malique à 3,5", {})[1]['malic'],
                                             "3.5",
                                             "Malic regex failed")
      assert_equal(DukeParsing.extract_operatoryMode("Récolte manuelle", {})[1]['operatorymode'],
                                                     "manuel",
                                                     "OperatoryMode regex failed")
      assert_equal(DukeParsing.extract_duration_fr("Pendant 45 minutes")[0],
                                                   45,
                                                   "Did not match work duration correctly")
      assert_equal(DukeParsing.extract_duration_fr("Travail de 2 heures")[0],
                                                   120,
                                                   "Did not match work duration correctly")
      assert_equal(DukeParsing.extract_duration_fr("Travail de 3h40")[0],
                                                   220,
                                                   "Did not match work duration correctly")
      yes = Date.yesterday
      assert_equal(DukeParsing.extract_date_fr("hier à 13h54")[0],
                                               DateTime.new(yes.year, yes.month, yes.day, 13, 54, 0, "+02:00"),
                                               "Did not match work duration correctly")
      assert_equal(DukeParsing.extract_date_fr("Le 14 juillet au matin")[0],
                                               DateTime.new(yes.year, 7, 14, 10, 0, 0, "+02:00"),
                                               "Did not match work duration correctly")
    end
    test 'plant area extraction' do
      assert_equal(DukeParsing.extract_plant_area("50% de bernessard", [{:key=>85, :name=>"Bernessard", :indexes=>[2], :distance=>1}]),
                                                  [{:key=>85, :name=>"Bernessard", :indexes=>[2], :distance=>1, :area=>50}],
                                                  "Could not find percentage of a plant")

      assert_equal(DukeParsing.extract_plant_area("Sur Bernessard", [{:key=>85, :name=>"Bernessard", :indexes=>[1], :distance=>1}]),
                                                  [{:key=>85, :name=>"Bernessard", :indexes=>[1], :distance=>1, :area=>100}],
                                                  "Does not attribute 100% of a plant when not specified")
    end
  end
end
