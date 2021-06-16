module ConvertCvi
  class ConvertCviLandParcel
    def initialize(cvi_land_parcel, activity_open_from)
      @cvi_land_parcel = cvi_land_parcel
      @cvi_statement = cvi_land_parcel.cvi_statement
      @activity_open_from = activity_open_from
      @activity = cvi_land_parcel.activity
      @planting_campaign = Campaign.of(cvi_land_parcel.planting_campaign)
      # 1 Find or create a cultivable zone with cvi cultivable CultivableZone
      @cultivable_zone = ConvertCviCultivableZone.call(cvi_land_parcel.cvi_cultivable_zone)
    end

    def self.call(cvi_land_parcel, activity_open_from)
      new(cvi_land_parcel, activity_open_from).call
    end

    def call
      # Open activity for campaign
      open_activity

      # Find or create an activity_production according to current cvi_land_parcel informations
      # activity_production will created land_parcel automaticaly
      find_or_create_production

      # Find or create a plant according to current cvi_land_parcel informations
      create_plant
    end

    def open_activity
      if activity_open_from < Campaign.of(Time.zone.now.year).harvest_year
        (activity_open_from..(Campaign.of(Time.zone.now.year).harvest_year + 1)).to_a.each do |harvest_year|
          activity.budgets.find_or_create_by!(campaign: Campaign.of(harvest_year))
        end
      else
        activity.budgets.find_or_create_by!(campaign: Campaign.of(activity_open_from))
      end
    end

    def find_or_create_production
      # find existing productions by shape matching and provider
      if activity.productions.any?
        productions = activity.productions.support_shape_matching(cvi_land_parcel.shape, 0.02)
        productions = activity.productions.of_provider_data('cvi_land_parcel_id', cvi_land_parcel.id.to_s) if productions.empty?
      end

      @activity_production = if productions.present?
                               productions.first
                             else
                               activity.productions.create(
                                 ActivityProductions::DefaultAttributesValueBuilder
                                   .new(activity, planting_campaign)
                                   .build
                                   .merge( { cultivable_zone: cultivable_zone, support_shape: cvi_land_parcel.shape })
                               )
                             end

      activity_production.update!(
        support_nature: :headland_cultivation,
        usage: :fruit,
        starting_year: cvi_land_parcel.planting_campaign.to_i,
        started_on: Date.new(cvi_land_parcel.planting_campaign.to_i - 1,
                             activity.production_started_on.month,
                             activity.production_started_on.day),
        stopped_on: production_stopped_on,
        custom_name: cvi_land_parcel.name,
        provider: build_provider(cvi_statement.id, cvi_land_parcel.id)
      )
    end

    def create_plant
      # create only if no plant exist with the current cvi_land_parcel_id
      return if Plant.of_provider_data('cvi_land_parcel_id', cvi_land_parcel.id.to_s).any?

      # WAITING FOR Conditionning branch
      # category = ProductNatureCategory.import_from_lexicon(:amortized_plant)
      # nature = ProductNature.import_from_lexicon(:crop)
      # variant = ProductNatureVariant.new(category: category, nature: nature)

      type_of_occupancy = cvi_land_parcel.cvi_cadastral_plants.first.type_of_occupancy.presence if cvi_land_parcel.cvi_cadastral_plants.present?

      name = "#{activity.name} #{planting_campaign.name} #{cultivable_zone.name} #{cvi_land_parcel.vine_variety.short_name}"
      plant_with_same_name = Plant.where('name like ?', "#{name}%").count
      index = " n° #{plant_with_same_name + 1}" if plant_with_same_name.positive?

      variant = ProductNatureVariant.import_from_nomenclature(:vine_grape_crop)
      start_at = Time.zone.local(cvi_land_parcel.planting_campaign.to_i, 1, 1)
      vine_variety = cvi_land_parcel.vine_variety
      certification_label = cvi_land_parcel.designation_of_origin.product_human_name_fra if cvi_land_parcel.designation_of_origin
      plant = Plant.create!(variant_id: variant.id,
                            name: "#{cvi_land_parcel.name} | #{vine_variety.specie_name}",
                            initial_born_at: start_at,
                            dead_at: (cvi_land_parcel.land_modification_date if cvi_land_parcel.state == 'removed_with_authorization'),
                            initial_shape: cvi_land_parcel.shape,
                            specie_variety: { specie_variety_name: vine_variety.short_name,
                                              specie_variety_uuid: vine_variety.id,
                                              specie_variety_providers: vine_variety.class.name },
                            type_of_occupancy: (type_of_occupancy == 'tenant_farming' ? :rent : type_of_occupancy),
                            initial_owner: (Entity.of_company if type_of_occupancy == :owner),
                            activity_production_id: activity_production.id,
                            provider: build_provider(cvi_statement.id, cvi_land_parcel.id))
      plant.read!(:rows_interval, cvi_land_parcel.inter_row_distance_value.in(cvi_land_parcel.inter_row_distance_unit.to_sym), at: start_at)
      plant.read!(:plants_interval, cvi_land_parcel.inter_vine_plant_distance_value.in(cvi_land_parcel.inter_vine_plant_distance_unit.to_sym), at: start_at)
      plant.read!(:certification_label, certification_label, at: start_at) if certification_label
      plant.read!(:shape, cvi_land_parcel.shape, at: start_at, force: true)
    end

    private

    attr_accessor :activity, :context, :cvi_land_parcel, :activity_production, :activity_open_from, :planting_campaign, :cultivable_zone, :cvi_statement

    def build_provider(cvi_statement_id, cvi_land_parcel_id)
      {
        vendor: 'ekylibre',
        name: 'cvi_statement',
        id: cvi_statement_id,
        data: {
          cvi_land_parcel_id: cvi_land_parcel_id
        }
      }
    end

    def production_stopped_on
      return cvi_land_parcel.land_modification_date if cvi_land_parcel.state == :removed_with_authorization

      if cvi_land_parcel.state == :planted && Date.today.year - cvi_land_parcel.planting_campaign.to_i > activity.life_duration
        Date.new(Time.zone.now.year + 1, activity.production_stopped_on.month, activity.production_stopped_on.day)
      else
        Date.new(cvi_land_parcel.planting_campaign.to_i + activity.life_duration, activity.production_stopped_on.month, activity.production_stopped_on.day)
      end
    end
  end
end
