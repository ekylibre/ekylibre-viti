namespace :lexicon do
  task post_processing: :environment do
    Lexicon.execute_post_processing
  end
end