class ConvertCvi < ApplicationInteractor
  before do
    context.count_land_parcel_created = 0
  end

  def call
    @cvi_statement = CviStatement.find(context.cvi_statement_id)
    ActiveRecord::Base.transaction do
      convert_cvi_land_parcel
    end
  end

  private

  def convert_cvi_land_parcel
    begin
      @cvi_statement.cvi_land_parcels.each do |cvi_land_parcel|
        activity = cvi_land_parcel.activity
        unless activity
          context.fail!(error: :missing_activity_on_cvi_land_parcel)
        end

        planting_campaign = Campaign.of(cvi_land_parcel.planting_campaign)

        # 1 Find or create a cultivable zone with cvi cultivable CultivableZone
        cultivable_zone = find_or_create_cz_with_cvi_cz(cvi_land_parcel.cvi_cultivable_zone)

        # 2 Find or create an activity_production according to current cvi_land_parcel informations
        # activity_production will created land_parcel automaticaly

        # find existing productions by shape matching and providers
        if activity.productions.any?
          productions = activity.productions.support_shape_matching(cvi_land_parcel.shape, 0.02)
          productions ||= activity.productions.where('providers @> ?', { cvi_land_parcel_id: cvi_land_parcel.id }.to_json)
        end
        activity_production = if productions.present?
                                productions.first
                              else
                                activity.productions.new(cultivable_zone: cultivable_zone, support_shape: cvi_land_parcel.shape)
                              end
        activity_production.update!(
          support_nature: :headland_cultivation,
          usage: :fruit,
          planting_campaign: planting_campaign,
          started_on: Date.new(cvi_land_parcel.planting_campaign.to_i + activity.start_state_of_production.keys.first.to_i,
                               activity.production_started_on.month,
                               activity.production_started_on.day),
          stopped_on: Date.new(cvi_land_parcel.planting_campaign.to_i + activity.life_duration.to_i,
                               activity.production_started_on.month,
                               activity.production_started_on.day),
          providers: { 'cvi_land_parcel_id' => cvi_land_parcel.id }
        )

        context.count_land_parcel_created += 1

        # 3 Find or create a plant according to current cvi_land_parcel informations
        # create only if no plant exist with the current cvi_land_parcel_id
        next if Plant.where('providers @> ?', { cvi_land_parcel_id: cvi_land_parcel.id }.to_json).any?

        # WAITING FOR Conditionning branch
        # category = ProductNatureCategory.import_from_lexicon(:amortized_plant)
        # nature = ProductNature.import_from_lexicon(:crop)
        # variant = ProductNatureVariant.new(category: category, nature: nature)

        # TODO: set rootstock as reading
        # if cvi_land_parcel.rootstocks.any?
        #   plant_rootstocks_attributes = cvi_land_parcel.cvi_cadastral_plant_cvi_land_parcels.map do |ccp_clp|
        #     { percentage: ccp_clp.percentage.to_f, rootstock_id: ccp_clp.cvi_cadastral_plant.rootstock_id }
        #   end
        # end
        type_of_occupancy = cvi_land_parcel.cvi_cadastral_plants.first.type_of_occupancy.presence if cvi_land_parcel.cvi_cadastral_plants.present?

        name = "#{activity.name} #{planting_campaign.name} #{cultivable_zone.name} #{cvi_land_parcel.vine_variety.specie_name}"
        plant_with_same_name = Plant.where('name like ?', "%#{name}").count
        index = " n° #{plant_with_same_name + 1}" if plant_with_same_name.positive?

        variant = ProductNatureVariant.import_from_nomenclature(:vine_grape_crop)
        start_at = Time.new(cvi_land_parcel.planting_campaign.to_i, 1, 1)
        vine_variety = cvi_land_parcel.vine_variety

        plant = Plant.create!(variant_id: variant.id,
                              work_number: 'V_' + cvi_land_parcel.planting_campaign + '_' + cvi_land_parcel.name,
                              name: "name#{index}",
                              initial_born_at: start_at,
                              initial_dead_at: (cvi_land_parcel.land_modification_date if cvi_land_parcel.state == 'removed_with_authorization'),
                              initial_shape: cvi_land_parcel.shape,
                              specie_variety: { name: vine_variety.specie_name,
                                                uuid: vine_variety.id,
                                                providers: vine_variety.class.name },
                              # designation_of_origin: cvi_land_parcel.designation_of_origin,
                              # plant_rootsotcks_attributes: plant_rootstocks_attributes,
                              type_of_occupancy: type_of_occupancy,
                              initial_owner: Entity.of_company,
                              activity_production_id: activity_production.id,
                              providers: { cvi_land_parcel_id: cvi_land_parcel.id })
        plant.read!(:rows_interval, cvi_land_parcel.inter_row_distance_value.in(cvi_land_parcel.inter_row_distance_unit.to_sym), at: start_at)
        plant.read!(:plants_interval, cvi_land_parcel.inter_vine_plant_distance_value.in(cvi_land_parcel.inter_vine_plant_distance_unit.to_sym), at: start_at)
        plant.read!(:shape, cvi_land_parcel.shape, at: start_at, force: true)
      end
    rescue StandardError => exception
      context.fail!(error: exception.message)
    end
  end

  def find_or_create_cz_with_cvi_cz(cvi_cz)
    # check if cvi cz shape covered existing cz shape with 95 to 98% accuracy
    cvi_cz_shape = ::Charta.new_geometry(cvi_cz.shape)
    # check if cover at 95%
    cvi_cz_inside_cultivable_zone = CultivableZone.shape_covering(cvi_cz_shape, 0.05)
    unless cvi_cz_inside_cultivable_zone.any?
      # check if match at 95%
      cvi_cz_inside_cultivable_zone = CultivableZone.shape_matching(cvi_cz_shape, 0.05)
      # check if intersect at 98%
      cvi_cz_inside_cultivable_zone ||= CultivableZone.shape_intersecting(cvi_cz_shape, 0.02)
    end
    # select the first if one exist which cover, match or intersect
    if cvi_cz_inside_cultivable_zone.any?
      cvi_cz_inside_cultivable_zone.first
    else
      # or find or create it by name
      CultivableZone.create_with(
        name: cvi_cz.name,
        description: "Convert from CVI ID : #{cvi_cz.cvi_statement_id}",
        shape: cvi_cz.shape
      ).find_or_create_by(name: cvi_cz.name)
    end
  end
end
