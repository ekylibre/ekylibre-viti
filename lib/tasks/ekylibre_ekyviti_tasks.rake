namespace :test do
  Rake::TestTask.new :ekylibre_ekyviti do |t|
    t.libs << 'test'
    t.verbose = false
    t.warning = false
    t.pattern = "#{EkylibreEkyviti::Engine.root}/test/{models,controllers,mailers,jobs,helpers,lib,interactors,exchangers}/**/*_test.rb"
  end
end
