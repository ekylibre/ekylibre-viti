module EkylibreEkyviti
  class Engine < ::Rails::Engine
    config.after_initialize do
      ::Backend::BaseController.prepend_view_path EkylibreEkyviti::Engine.root.join('app/views')
    end

    initializer 'ekylibre_ekyviti.assets.precompile' do |app|
      app.config.assets.precompile += %w(ekyviti.scss ekyviti.js themes/bordeaux/all.scss themes/cognac/all.scss *.svg)
    end

    initializer :ekylibre_ekyviti_extend_with_ekyviti_navigation do |_app|
      EkylibreEkyviti::ExtNavigation.add_navigation_xml_to_existing_tree
    end

    initializer :ekylibre_ekyviti_i18n do |app|
      app.config.i18n.load_path += Dir[EkylibreEkyviti::Engine.root.join('config', 'locales', '**', '*.yml')]
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

    initializer :register_ekyviti_plugin, after: :load_config_initializers do
      Ekylibre::Application.instance.plugins << EkylibreEkyviti::Plugin.new
    end

    initializer :ekylibre_ekyviti_javascript do
      Rails.root.join('tmp', 'plugins', 'javascript-addons', 'plugins.js.coffee').open('a') do |f|
        f.write(
          "#= require eky-cartography \n
           #= require ekyviti \n"
        )
      end
    end

    initializer :ekylibre_ekyviti_stylesheet do
      Rails.root.join('tmp', 'plugins', 'theme-addons', 'themes', 'tekyla', 'plugins.scss').open('a') do |f|
        f.write <<~SCSS
          // ekyviti
          @import 'cartography';
          @import 'ekyviti';
        SCSS
      end
    end
  end
end
