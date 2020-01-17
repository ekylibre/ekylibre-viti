class ConcatCviLandParcels < ApplicationInteractor

  def call
    @cvi_land_parcel = context.cvi_land_parcels.first.dup
    nullify_uncommon_attributes
    cvi_land_parcel.land_parcel_rootstocks.build(rootstock_id: common_rootstock_id)
    context.cvi_land_parcel = cvi_land_parcel
  end

  private

    def common_rootstock_id
      rootstock_ids = context.cvi_land_parcels.collect { |cvi_land_parcel| cvi_land_parcel.land_parcel_rootstocks&.collect(&:rootstock_id) }.flatten.uniq
      rootstock_ids.first if rootstock_ids.length == 1
    end

    def nullify_uncommon_attributes
      attributes_with_different_values = CviLandParcel.column_names.reject { |c| c == 'id' }.map do |a|
        a if context.cvi_land_parcels.collect { |r| r.try(a) }.uniq.length > 1
      end.compact
      attributes_with_different_values.each do |a|
        cvi_land_parcel.send("#{a}=", nil)
      end
    end

    attr_accessor :cvi_land_parcel
end
