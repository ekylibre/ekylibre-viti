module EkylibreEkyviti
  class Engine < ::Rails::Engine
    initializer 'ekylibre_ekyviti.assets.precompile' do |app|
      app.config.assets.precompile += %w(ekyviti.scss ekyviti.js)
    end
  end
end
