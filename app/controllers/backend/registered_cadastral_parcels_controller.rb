module Backend
  class RegisteredCadastralParcelsController < Backend::BaseController
    respond_to :json

    def index
      records_in_bounding_box = RegisteredCadastralParcel.in_bounding_box(params[:bounding_box])

      records_not_in_cvi = records_in_bounding_box.joins(<<~SQL).where('land_parcel_id IS NULL')
        LEFT JOIN cvi_cadastral_plants
        ON registered_cadastral_parcels.id = cvi_cadastral_plants.land_parcel_id
      SQL

      records = records_not_in_cvi.collect do |r|
        [r[:shape], { uuid: r.id, cadastral_ref: r.id[/\D{1,2}\d*/].tr('0', '') }]
      end.transpose
      land_parcel_zones = Charta.new_geometry "GEOMETRYCOLLECTION(#{Maybe(records.first).join(',').or_else { '' }})"
      respond_with land_parcel_zones.to_json_feature_collection(records.last || [])
    end
  end
end
