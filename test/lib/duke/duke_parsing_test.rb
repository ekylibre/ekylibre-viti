require 'test_helper'

module Duke
  class DukeParsingTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
    DukeParsing = Duke::DukeParsing.new
    test 'create words combos' do
      _(DukeParsing.create_words_combo("This is a sentence written to try the function").length).must_equal 30 ,"Not enough combos of words are created"
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
      # No changes to the list, overlapping indexes and smaller distance
      _(DukeParsing.add_to_recognize_final(saved_hash_no_index, target_list, all_lists)).must_equal target_list
      # Changes to the list, overlapping indexes and greater distance 
      _(DukeParsing.add_to_recognize_final(saved_hash_yes_index, target_list, all_lists)).must_equal  [saved_hash_yes_index]
      _(DukeParsing.add_to_recognize_final(saved_hash_no_other_list, target_list, all_lists)).must_equal target_list, "Other list not supported"
      _(DukeParsing.add_to_recognize_final(saved_hash_yes_other_list, target_list, all_lists)).must_equal [saved_hash_yes_other_list]
      _(DukeParsing.add_to_recognize_final(saved_hash_yes, target_list, all_lists)).must_equal [target_list[0], saved_hash_yes]
    end
  end
end
