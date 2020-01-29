class GenerateCviCultivableZones < ApplicationInteractor

  def call
    get_cvi_cultivable_zones_properties
    ActiveRecord::Base.transaction do
      create_cvi_cultivables_zones
    end
  end

  private

  def get_cvi_cultivable_zones_properties
    result = ActiveRecord::Base.connection.execute("
      SELECT ARRAY_AGG(id) AS cvi_cadastral_plant_ids,
        St_AStext(
          ST_Simplify(
            ST_Union(
              ARRAY_AGG(shape)
            ),0.000000001
          )
        ) AS shape
      FROM  (SELECT cvi_cadastral_plants.*, shape, ST_ClusterDBSCAN(shape, 0, 1) OVER() AS clst
	            FROM cvi_cadastral_plants
              LEFT JOIN lexicon.cadastral_land_parcel_zones  ON cvi_cadastral_plants.land_parcel_id = cadastral_land_parcel_zones.id
              WHERE cvi_statement_id = #{context.cvi_statement.id} AND land_parcel_id IS NOT NULL) q
      GROUP BY clst;").to_a.each { |e| e['cvi_cadastral_plant_ids'] = e['cvi_cadastral_plant_ids'].delete('{}').split(',') }
    @cvi_cultivable_zones = result
  end

  def create_cvi_cultivables_zones
    @cvi_cultivable_zones.each_with_index do |cvi_cultivable_zone, i|
      index = (i + 1).to_s.rjust(2, '0')
      cvi_cadastral_plants = CviCadastralPlant.find(cvi_cultivable_zone['cvi_cadastral_plant_ids'])
      locations = cvi_cadastral_plants.map(&:location).uniq{ |e| e.insee_number && e.locality}
      declared_area = cvi_cadastral_plants.collect(&:area).sum
      shape = cvi_cultivable_zone['shape']

      cvi_cultivable_zone = CviCultivableZone.create(
        name: "Zone ##{index}",
        cvi_statement_id: context.cvi_statement.id,
        declared_area: declared_area,
        shape: shape
      )
      locations.each do |r|
        Location.create(localizable: cvi_cultivable_zone, insee_number: r.insee_number, locality: r.locality)
      end
      cvi_cultivable_zone.cvi_cadastral_plants << cvi_cadastral_plants
    end
  end
end