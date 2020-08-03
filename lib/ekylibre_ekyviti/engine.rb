module EkylibreEkyviti
  class Engine < ::Rails::Engine
    config.after_initialize do
      ::Backend::BaseController.prepend_view_path EkylibreEkyviti::Engine.root.join('app/views')
    end

    initializer :themes do |app|
      app.config.themes += %w[bordeaux cognac]
    end

    initializer 'ekylibre_ekyviti.assets.precompile' do |app|
      app.config.assets.precompile += %w(ekyviti.scss ekyviti.js themes/bordeaux/all.css themes/cognac/all.css)
    end

    initializer :extend_navigation do |_app|
      EkylibreEkyviti::ExtNavigation.add_navigation_xml_to_existing_tree
    end

    initializer :extend_lexicon do |_app|
      ::Lexicon.include EkylibreEkyviti::Lexicon
    end

    initializer :i18n do |app|
      app.config.i18n.load_path += Dir[EkylibreEkyviti::Engine.root.join('config', 'locales', '**', '*.yml')]
    end
  end
end
