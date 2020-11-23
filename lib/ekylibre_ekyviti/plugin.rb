module EkylibreEkyviti
  class Plugin
    def themes
      %w[bordeaux cognac].map { |name| Ekylibre::Plugin::Theme.new(name, "#{EkylibreEkyviti::Engine.root.join('app', 'assets', 'stylesheets', 'themes') + '/' + name}/all.css")}
    end
  end
end