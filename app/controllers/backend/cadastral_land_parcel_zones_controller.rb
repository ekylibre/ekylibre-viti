module Backend
  class CadastralLandParcelZonesController < Backend::BaseController
    respond_to :json

    def index
      selected_ids = params[:selected_ids] ? params[:selected_ids].split(',') : []

      records_in_bounding_box = CadastralLandParcelZone.in_bounding_box(params[:bounding_box])

      records_not_in_cvi = records_in_bounding_box.joins(<<~SQL).where('land_parcel_id IS NULL')
        LEFT JOIN cvi_cadastral_plants
        ON cadastral_land_parcel_zones.id = cvi_cadastral_plants.land_parcel_id
      SQL

      records = records_not_in_cvi.collect do |r|
        [r[:shape], { uuid: r.id, cadastral_ref: r.id[/\D{1,2}\d*/].tr('0', '') }]
      end.transpose
      crop_zones = Charta.new_geometry "GEOMETRYCOLLECTION(#{Maybe(records.first).join(',').or_else { '' }})"
      respond_with crop_zones.to_json_feature_collection(records.last || [])
    end
  end
end
