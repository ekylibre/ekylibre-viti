namespace :test do
  parts = %i[integrations concepts interactors controllers exchangers helpers jobs lib models services validators]
  plugin_test_path = EkylibreEkyviti::Engine.root.join('test')
  plugin_parts = Dir.entries(File.join(plugin_test_path)).map(&:to_sym) & parts

  namespace 'ekylibre_ekyviti' do
    plugin_parts.each do |plugin_part|
      Rake::TestTask.new plugin_part do |t|
        t.libs << 'test'
        t.warning = false
        t.pattern = "#{plugin_test_path}/#{plugin_part}/**/*_test.rb"
      end
    end

    Rake::TestTask.new :all do |t|
      t.libs << 'test'
      t.warning = false
      t.pattern = "#{plugin_test_path}/*/**/*_test.rb"
    end
  end
end
