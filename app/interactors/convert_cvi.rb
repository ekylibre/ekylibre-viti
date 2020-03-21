class ConvertCvi < ApplicationInteractor

  def self.call(params)
    interactor = new(params)
    interactor.run
    interactor
  end

  attr_reader :cvi_statement, :log_result, :error

  def initialize(params)
    @cvi_statement = CviStatement.find(params[:cvi_statement_id])
    @log_result = {}
  end

  def run
    @log_result[:count_land_parcel_created] = 0

    begin
      @cvi_statement.cvi_land_parcels.each do |cvi_land_parcel|
        # 0 Update activity attributes
        # REMOVE WHEN MERGING BRANCH PERENNIAL ACTIVITY
        activity = cvi_land_parcel.activity
        attributes = {
          cultivation_variety: 'vitis',
          production_cycle: :perennial,
          production_started_on: Date.new(2000,11,01),
          production_stopped_on: Date.new(2001,10,31),
          start_state_of_production: {"3" => "n_3_4_leaf"},
          life_duration: 30
        }
        activity.update_attributes(attributes)

        # 1 Find or create a cultivable zone with cvi cultivable CultivableZone
        cultivable_zone = find_or_create_cz_with_cvi_cz(cvi_land_parcel.cvi_cultivable_zone)

        # 2 Find or create an activity_production according to current cvi_land_parcel informations
        # activity_production will created land_parcel automaticaly
        productions = activity.productions.support_shape_matching(cvi_land_parcel.shape, 0.02) if activity.productions.any?
        activity_production = if productions.any?
                                productions.first
                              else
                                activity.productions.new(cultivable_zone: cultivable_zone, support_shape: cvi_land_parcel.shape)
                              end
        activity_production.support_nature = :cultivation
        activity_production.usage = :fruit
        activity_production.started_on = Date.new(cvi_land_parcel.planting_campaign.to_i, activity.production_started_on.month, activity.production_started_on.day)
        activity_production.stopped_on = Date.new(cvi_land_parcel.planting_campaign.to_i + activity.life_duration.to_i, activity.production_started_on.month, activity.production_started_on.day)
        activity_production.save!

        @log_result[:count_land_parcel_created] += 1

        # 3 Find or create a plant according to current cvi_land_parcel informations
        if cvi_land_parcel.state == "planted"
          # WAITING FOR Conditionning branch
          # category = ProductNatureCategory.import_from_lexicon(:amortized_plant)
          # nature = ProductNature.import_from_lexicon(:crop)
          # variant = ProductNatureVariant.new(category: category, nature: nature)
          variant = ProductNatureVariant.import_from_nomenclature(:vine_grape_crop)
          start_at = Time.new(cvi_land_parcel.planting_campaign.to_i, activity.production_started_on.month, activity.production_started_on.day)
          plant = Plant.create!(variant_id: variant.id,
                                 work_number: 'V_' + cvi_land_parcel.planting_campaign + '_' + cvi_land_parcel.name,
                                 name: cvi_land_parcel.name,
                                 initial_born_at: start_at,
                                 initial_shape: cvi_land_parcel.shape,
                                 initial_owner: Entity.of_company
                               )
          plant.read!(:population, cvi_land_parcel.calculated_area_value, at: start_at)
          plant.read!(:rows_interval, cvi_land_parcel.inter_row_distance_value.in(inter_row_distance_unit.to_sym), at: start_at)
          plant.read!(:plants_interval, cvi_land_parcel.inter_vine_plant_distance_value.in(inter_vine_plant_distance_unit.to_sym), at: start_at)
          plant.read!(:shape, cvi_land_parcel.shape, at: start_at, force: true)
        end

      end
    rescue StandardError => exception
      fail!(exception.message)
      nil
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
      cultivable_zone = cvi_cz_inside_cultivable_zone.first
    # or find or create it by name
    else
      cultivable_zone = CultivableZone.create_with(
        name: cvi_cz.name,
        description: "Convert from CVI ID : #{cvi_cz.cvi_statement_id}",
        shape: cvi_cz.shape
      ).find_or_create_by(name: cvi_cz.name)
    end
    cultivable_zone
  end

  def success?
    @error.nil?
  end

  def fail?
    !success
  end

  private

  def fail!(error)
    @error = error
  end

  attr_accessor :cvi_land_parcels, :activities, :campaign
end
