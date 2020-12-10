module EkylibreEkyviti
    module PlantsControllerExt
      extend ActiveSupport::Concern
  
      included do
        before_action :set_views_path

        def set_views_path
          prepend_view_path EkylibreEkyviti::Engine.root.join('app', 'views')
        end
      end
    end
  end
  