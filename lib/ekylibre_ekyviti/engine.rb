module EkylibreEkyviti
  class Engine < ::Rails::Engine
    config.after_initialize do
      ::Backend::BaseController.prepend_view_path EkylibreEkyviti::Engine.root.join('app/views')
    end

    initializer :ekylibre_ekyviti_themes do |app|
      app.config.themes += %w[bordeaux cognac]
    end

    initializer 'ekylibre_ekyviti.assets.precompile' do |app|
      app.config.assets.precompile += %w(ekyviti.scss ekyviti.js themes/bordeaux/all.css themes/cognac/all.css *.svg)
    end

    initializer :ekylibre_ekyviti_extend_with_ekyviti_navigation do |_app|
      EkylibreEkyviti::ExtNavigation.add_navigation_xml_to_existing_tree
    end

    initializer :ekylibre_ekyviti_extend_lexicon do |_app|
      ::Lexicon.include EkylibreEkyviti::Lexicon
    end

    initializer :ekylibre_ekyviti_i18n do |app|
      app.config.i18n.load_path += Dir[EkylibreEkyviti::Engine.root.join('config', 'locales', '**', '*.yml')]
    end

    initializer :ekylibre_ekyviti_extend_controllers do |_app|
      ::Backend::ActivitiesController.include Backend::ActivitiesControllerExt
    end

    initializer :ekylibre_ekyviti_restfully_manageable do |app|
      app.config.x.restfully_manageable.view_paths << EkylibreEkyviti::Engine.root.join('app', 'views')
    end

    initializer :ekylibre_ekyviti_extend_measure do |_app|
      ::Measure.prepend EkylibreEkyviti::MeasureExt
    end
    initializer :ekylibre_ekyviti_beehive do |app|
      app.config.x.beehive.cell_controller_types << :weather_vine_spraying_map
    end
  end
end
