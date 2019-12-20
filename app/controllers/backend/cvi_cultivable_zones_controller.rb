module Backend
  class CviCultivableZonesController < Backend::CviBaseController
    manage_restfully only: %i[edit destroy show]

    def index
      records = CviStatement.find(params[:id]).cvi_cultivable_zones.collect do |r|
        { uuid: r.id, shape: r.shape.to_json_object, name: r.name, status: r.land_parcels_status }
      end
      render json: records.compact.to_json
    end

    def update
      return unless @cvi_cultivable_zone = find_and_check(:cvi_cultivable_zone)

      @cvi_cultivable_zone.attributes = permitted_params
      if @cvi_cultivable_zone.save
        notify_success(:record_x_updated, record: @cvi_cultivable_zone.model_name.human, column: @cvi_cultivable_zone.human_attribute_name(:name), name: @cvi_cultivable_zone.send(:name))
      else
        render action: :edit
      end
    end

    def delete_modal; end

    def generate_cvi_land_parcels
      cvi_cultivable_zone = CviCultivableZone.find(params[:id])
      cvi_cadastral_plants = cvi_cultivable_zone.cvi_cadastral_plants
      cvi_cadastral_plants.each do |r|
        declared_area = r.area
        shape = r.shape.to_rgeo
        calculated_area = Measure.new(shape.area, :square_meter).convert(:hectare)

        cvi_land_parcel = CviLandParcel.create(
          name: r.cadastral_reference,
          designation_of_origin_id: r.designation_of_origin_id,
          vine_variety_id: r.vine_variety_id,
          calculated_area: calculated_area,
          declared_area: declared_area,
          inter_vine_plant_distance: r.inter_vine_plant_distance,
          inter_row_distance: r.inter_row_distance,
          state: r.state,
          shape: shape,
          cvi_cultivable_zone_id: cvi_cultivable_zone.id,
          planting_campaign: r.planting_campaign
        )
        LandParcelRootstock.create(land_parcel: cvi_land_parcel, rootstock_id: r.rootstock_id)
        Location.create(localizable: cvi_land_parcel, locality: r.location.locality, insee_number: r.location.insee_number) 
      end
      redirect_to action: 'show', id: cvi_cultivable_zone.id
    end

    def confirm_cvi_land_parcels
      cvi_cultivable_zone = CviCultivableZone.find(params[:id])
      shape = CviLandParcel.select('St_AStext(ST_Union(ARRAY_AGG(shape))) AS shape').where(cvi_cultivable_zone_id: cvi_cultivable_zone.id)[0].shape
      calculated_area = Measure.new(shape.area, :square_meter).convert(:hectare)
      cvi_cultivable_zone.update(shape: shape.to_rgeo, calculated_area: calculated_area, land_parcels_status: :created)
      redirect_to backend_cvi_statement_conversion_path(cvi_cultivable_zone.cvi_statement)
    end

    list(:cvi_land_parcels, order: 'name DESC', model: :formatted_cvi_land_parcels, conditions: { cvi_cultivable_zone_id: 'params[:id]'.c }) do |t|
      t.column :id, hidden: true
      t.action :edit, url: { controller: 'cvi_land_parcels', action: 'edit', remote: true }
      t.column :name
      t.column :communes
      t.column :localities
      t.column :designation_of_origin_name
      t.column :vine_variety_name
      t.column :declared_area_formatted, label: :declared_area
      t.column :calculated_area_formatted, label: :calculated_area
      t.column :rootstocks
      t.column :planting_campaign
      t.column :inter_vine_plant_distance_value
      t.column :inter_row_distance_value
      t.column :state
    end

    def edit_cvi_land_parcels
      cvi_cultivable_zone = CviCultivableZone.find(params[:id])
      cvi_cultivable_zone.update(land_parcels_status: :not_created) if cvi_cultivable_zone.land_parcels_status == :created
      redirect_to backend_cvi_cultivable_zone_path(cvi_cultivable_zone)
    end
  end
end
