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
      activity_open_from = @cvi_statement.campaign.harvest_year
      @cvi_statement.cvi_land_parcels.each do |cvi_land_parcel|
        activity = cvi_land_parcel.activity
        unless activity
          context.fail!(error: :missing_activity_on_cvi_land_parcel)
        end

        (activity_open_from..Campaign.at.first.harvest_year).to_a.each do |harvest_year|
          activity.budgets.find_or_create_by!(campaign: Campaign.of(harvest_year))
        end
        planting_campaign = Campaign.of(cvi_land_parcel.planting_campaign)
        # 1 Find or create a cultivable zone with cvi cultivable CultivableZone
        cultivable_zone = CultivableZone.find_or_create_with_cvi_cz(cvi_land_parcel.cvi_cultivable_zone)

        # 2 Find or create an activity_production according to current cvi_land_parcel informations
        # activity_production will created land_parcel automaticaly

        # find existing productions by shape matching and providers
        if activity.productions.any?
          productions = activity.productions.support_shape_matching(cvi_land_parcel.shape, 0.02)
          productions = activity.productions.where('providers @> ?', { cvi_land_parcel_id: cvi_land_parcel.id }.to_json) if productions.empty?
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
          started_on: Date.new(cvi_land_parcel.planting_campaign.to_i,
                               activity.production_started_on.month,
                               activity.production_started_on.day),
          stopped_on: Date.new(cvi_land_parcel.planting_campaign.to_i + activity.life_duration.to_i,
                               activity.production_stopped_on.month,
                               activity.production_stopped_on.day),
          providers: { 'cvi_land_parcel_id' => cvi_land_parcel.id }
        )

        # 3 Find or create a plant according to current cvi_land_parcel informations
        # create only if no plant exist with the current cvi_land_parcel_id
        next if Plant.where('providers @> ?', { cvi_land_parcel_id: cvi_land_parcel.id }.to_json).any?

        # WAITING FOR Conditionning branch
        # category = ProductNatureCategory.import_from_lexicon(:amortized_plant)
        # nature = ProductNature.import_from_lexicon(:crop)
        # variant = ProductNatureVariant.new(category: category, nature: nature)

        type_of_occupancy = cvi_land_parcel.cvi_cadastral_plants.first.type_of_occupancy.presence if cvi_land_parcel.cvi_cadastral_plants.present?

        name = "#{activity.name} #{planting_campaign.name} #{cultivable_zone.name} #{cvi_land_parcel.vine_variety.specie_name}"
        plant_with_same_name = Plant.where('name like ?', "%#{name}").count
        index = " n° #{plant_with_same_name + 1}" if plant_with_same_name.positive?

        variant = ProductNatureVariant.import_from_nomenclature(:vine_grape_crop)
        start_at = Time.new(cvi_land_parcel.planting_campaign.to_i, 1, 1)
        vine_variety = cvi_land_parcel.vine_variety
        certification_label = cvi_land_parcel.designation_of_origin.product_human_name_fra

        plant = Plant.create!(variant_id: variant.id,
                              work_number: 'V_' + cvi_land_parcel.planting_campaign + '_' + cvi_land_parcel.name,
                              name: "#{name}#{index}",
                              initial_born_at: start_at,
                              initial_dead_at: (cvi_land_parcel.land_modification_date if cvi_land_parcel.state == 'removed_with_authorization'),
                              initial_shape: cvi_land_parcel.shape,
                              specie_variety: { name: vine_variety.specie_name,
                                                uuid: vine_variety.id,
                                                providers: vine_variety.class.name },
                              type_of_occupancy: (type_of_occupancy == 'tenant_farming' ? :rent : type_of_occupancy),
                              initial_owner: (Entity.of_company if type_of_occupancy == :owner),
                              activity_production_id: activity_production.id,
                              providers: { cvi_land_parcel_id: cvi_land_parcel.id })
        plant.read!(:rows_interval, cvi_land_parcel.inter_row_distance_value.in(cvi_land_parcel.inter_row_distance_unit.to_sym), at: start_at)
        plant.read!(:plants_interval, cvi_land_parcel.inter_vine_plant_distance_value.in(cvi_land_parcel.inter_vine_plant_distance_unit.to_sym), at: start_at)
        plant.read!(:certification_label, certification_label, at: start_at)
        plant.read!(:shape, cvi_land_parcel.shape, at: start_at, force: true)
      end
    rescue StandardError => exception
      context.fail!(error: exception.message)
    end
  end
end
