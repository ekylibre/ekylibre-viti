class GenerateCviCultivableZonesInteractor
  include Interactor

  def call
    get_cvi_cultivable_zones
    create_cvi_cultivables_zones
  end

  private 
  

  def get_cvi_cultivable_zones
    result = ActiveRecord::Base.connection.execute("
      SELECT ARRAY_AGG(id) AS cvi_cadastral_plant_ids,
       St_AStext(ST_Union(ARRAY_AGG(shape))) AS shape
      FROM  (SELECT cvi_cadastral_plants.*, shape, ST_ClusterDBSCAN(shape, 0, 1) OVER() AS clst
	            FROM   demo.cvi_cadastral_plants cvi_cadastral_plants 
              LEFT JOIN lexicon.cadastral_land_parcel_zones  ON cvi_cadastral_plants.land_parcel_id = cadastral_land_parcel_zones.id
              WHERE cvi_statement_id = #{context.cvi_statement_id}
	      ) q
      GROUP BY clst;"
    ).to_a
    context.cvi_cultivable_zones = result
  end

  def create_cvi_cultivables_zones
    context.cvi_cultivable_zones.each_with_index do |cvi_cultivable_zone,i|
      cvi_cadastral_plants = CviCadastralPlant.find(cvi_cultivable_zone["cvi_cadastral_plant_ids"])

      communes = cvi_cadastral_plants.pluck(:commune).uniq.join(', ')
      cadastral_references = cvi_cadastral_plants.pluck(:work_number, :land_parcel_number) 
                                                 .map { |e| !e[1].blank? ? e.join('-') : e[0] }
                                                 .join(', ')
      declared_area = cvi_cultivable_zone["shape"]

      cvi_cultivable_zone = CviCultivableZone.create(
        name: "Zone ##{i + 1}", 
        cvi_statement_id: id, 
        communes: communes, 
        cadastral_references: cadastral_references, 
        declared_area: declared_area, 
        shape: declared_shape
      )

      cvi_cadastral_plant_ids.each do |cvi_cadastral_plant_id|
        cvi_cadastral_plants.update(cvi_cadastral_plant_id, cvi_cultivable_zone_id: cvi_cultivable_zone.id)
      end
    end
  end
end