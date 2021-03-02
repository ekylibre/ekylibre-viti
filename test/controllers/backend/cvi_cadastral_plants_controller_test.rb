require 'test_helper'
require_relative '../../test_helper'

module Backend
  class CviCadastralPlantsControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions except: %i[index update delete_modal]

    test '#update, update land_parcel if cadastral reference or location change' do
      cvi_cadastral_plant = create(:cvi_cadastral_plant, land_parcel_id: nil)
      location_id = cvi_cadastral_plant.location.id
      put :update, params:
        { id: cvi_cadastral_plant.id,
          cvi_cadastral_plant: {
            section: 'AB',
            work_number: '132',
            location_attributes: {
              id: location_id,
              registered_postal_zone_id: '91121_91720_BUNOBO_' 
            } 
          }
        }, xhr: true
      assert_equal '40004000AB0132', cvi_cadastral_plant.reload.land_parcel_id
    end
  end
end
