module EkylibreEkyviti
  class Engine < ::Rails::Engine
    initializer 'ekylibre_ekyviti.assets.precompile' do |app|
      app.config.assets.precompile += %w(ekyviti.scss ekyviti.js)
    end

    initializer :i18n do |app|
      app.config.i18n.load_path += Dir[EkylibreEkyviti::Engine.root.join('config', 'locales', '**', '*.yml')]
    end
  end
end