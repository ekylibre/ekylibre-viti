desc 'Create Sql vues for Ekyviti'
namespace :lexicon do
  task post_processing: :environment do
    EkylibreEkyviti::Lexicon.execute_post_processing
  end
end
