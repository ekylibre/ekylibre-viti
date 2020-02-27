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
      r.save!
    end

    # create associated locations
    context.cvi_land_parcel.locations.map(&:dup).each do |new_location|
      new_location.assign_attributes(localizable_id: new_cvi_land_parcel.id, localizable_type: new_cvi_land_parcel.class.name)
      new_location.save!
    end

    # create associated land_parcel_rootstocks
    context.cvi_land_parcel.land_parcel_rootstocks.map(&:dup).each do |new_land_parcel_rootstock|
      new_land_parcel_rootstock.assign_attributes(land_parcel_id: new_cvi_land_parcel.id, land_parcel_type: new_cvi_land_parcel.class.name)
      new_land_parcel_rootstock.save!
    end
  end

  def destroy_splitted_cvi_land_parcel
    context.cvi_land_parcel.destroy!
  end
end
