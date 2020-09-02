Rails.application.routes.draw do
  concern :list do
    get :list, on: :collection
  end

  concern :unroll do
    get :unroll, on: :collection
  end

  namespace :backend do
    resources :cvi_statements, concerns: %i[list] do
      member do
        patch :update_campaign
        get :list_cvi_cadastral_plants
        get :list_cvi_cadastral_plants_map
        resources :cvi_cadastral_plants, only: %i[index]
      end
    end

    resources :cvi_statement_conversions, concerns: %i[list], only: %i[show create] do
      member do
        get :convert_modal
        get :list_cvi_cultivable_zones
        get :reset
        post :convert
      end
    end

    resources :cvi_cultivable_zones do
      member do
        get :delete_modal
        get :generate_cvi_land_parcels
        get :confirm_cvi_land_parcels
        get :edit_cvi_land_parcels
        get :list_cvi_land_parcels
        get :reset_modal
        post :reset
        resources :cvi_land_parcels, only: %i[index]
      end
      collection do
        post :group
      end
    end

    resources :cvi_land_parcels, only: %i[edit update] do
      member do
        get :pre_split
        post :split
      end
      collection do
        post :group
        get :edit_multiple
        put :update_multiple
      end
    end

    resources :cvi_cadastral_plants, only: %i[destroy edit patch update], defaults: { :format => 'js' } do
      member do
        get :delete_modal
      end
    end

    resources :wine_incoming_harvests, concerns: :list do
      member do
        get :list_plants
        get :list_storages
      end
    end

    resources :wine_incoming_harvest_plants, only: [] do
      collection do
        get :net_harvest_area
      end
    end
  end
end
