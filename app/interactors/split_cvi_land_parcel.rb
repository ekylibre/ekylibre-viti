class SplitCviLandParcel < ApplicationInteractor
  def call
    ActiveRecord::Base.transaction do
      context.new_cvi_land_parcels_params.each do |params|
        create_new_cvi_land_parcels(params)
      end
      destroy_splitted_cvi_land_parcel
    end
  end

  private

  def create_new_cvi_land_parcels(new_cvi_land_parcel_params)
    cvi_land_parcel = context.cvi_land_parcel.dup
    cvi_land_parcel.save!
    new_cvi_land_parcel = cvi_land_parcel.tap do |r|
      r.assign_attributes(new_cvi_land_parcel_params)
      calculated_area = Measure.new(r.shape.area, :square_meter).convert(:hectare)
      r.declared_area = context.cvi_land_parcel.declared_area * (calculated_area / context.cvi_land_parcel.calculated_area)
      r.save!(context: :split_cvi_land_parcel)
    end

    # create associated locations
    context.cvi_land_parcel.locations.map(&:dup).each do |new_location|
      new_location.assign_attributes(localizable_id: new_cvi_land_parcel.id, localizable_type: new_cvi_land_parcel.class.name)
      new_location.save!
    end

    # set associated cvi_cadastral_plants
    new_cvi_land_parcel.cvi_cadastral_plants << context.cvi_land_parcel.cvi_cadastral_plants.first
  end

  def destroy_splitted_cvi_land_parcel
    context.cvi_land_parcel.destroy!
  end
end
