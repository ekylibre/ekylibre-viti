require 'test_helper'
module Backend
  class CviCultivableZonesControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions only: %i[edit destroy]

    describe('#delete_modal') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone) }

      it 'get delete_modal' do
        xhr :get, :delete_modal, id: cvi_cultivable_zone.id, format: :js
        assert_response :success
      end
    end

    describe('#update') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone) }

      it 'updates record' do
        xhr :put, :update, id: cvi_cultivable_zone.id, cvi_cultivable_zone: { name: 'new_name' }
        assert_equal 'new_name', cvi_cultivable_zone.reload.name
      end

      it 'responds with success' do
        xhr :put, :update, id: cvi_cultivable_zone.id, cvi_cultivable_zone: { name: 'new_name' }
        assert_response :success
      end
    end
  end
end