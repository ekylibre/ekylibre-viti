module EkylibreEkyviti
  class Engine < ::Rails::Engine
    initializer :themes do |app|
      app.config.themes += %w[bordeaux cognac]
    end

    initializer 'ekylibre_ekyviti.assets.precompile' do |app|
      app.config.assets.precompile += %w(ekyviti.scss ekyviti.js themes/bordeaux/all.css themes/cognac/all.css)
    end
  end
end
