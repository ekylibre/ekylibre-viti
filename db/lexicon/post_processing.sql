CREATE OR REPLACE FUNCTION area_formatted(area numeric) RETURNS VARCHAR(50) AS
    $$
    DECLARE
    ha_area_num  NUMERIC;
    ar_area_num  NUMERIC;
    ca_area_num  NUMERIC;
    ha_area  VARCHAR(50);
    ar_area  VARCHAR(50);
    ca_area  VARCHAR(50);
    result VARCHAR(50);
    BEGIN
    ha_area_num = TRUNC(area, 0);
    ar_area_num = TRUNC(area - ha_area_num, 2);
    ca_area_num = TRUNC(area - ha_area_num - ar_area_num, 4);

    ha_area = to_char(ha_area_num , '999');
    ar_area = to_char(ar_area_num * 100, 'FM00');
    ca_area = to_char(ca_area_num * 10000, 'FM00');

    result = CONCAT(ha_area,' ha ', ar_area,' a ',ca_area, ' ca');
    RETURN result;
    END;
    $$ LANGUAGE plpgsql;

DROP VIEW IF EXISTS formatted_cvi_cadastral_plants;

CREATE OR REPLACE VIEW formatted_cvi_cadastral_plants AS
SELECT 
	cvi_cadastral_plants.id AS id,
	land_parcel_id,
	locality,
	INITCAP(city_name) AS commune,
	
	CASE 
	  WHEN land_parcel_number IS NULL THEN 
	    CONCAT(section,' ', work_number)
	  ELSE
	   CONCAT(section,' ', work_number,'-',land_parcel_number ) 
	END AS cadastral_reference,
	
	designation_of_origins.product_human_name_fra AS designation_of_origin_name,
	INITCAP(vine_varieties.short_name) AS vine_variety_name,
	area_value,
	area_formatted(area_value) AS area_formatted,
	COALESCE(planting_campaign,'9999') planting_campaign,
	cadastral_ref_updated,

	CASE 
	  WHEN rootstock_id IS NULL THEN 
	    NULL	
	  ELSE
	   INITCAP(rootstocks.short_name)
	END AS rootstock,
	
	inter_vine_plant_distance_value :: int AS inter_vine_plant_distance_value,
	inter_row_distance_value :: int AS inter_row_distance_value,
	state,
	
	cvi_statement_id
	
FROM cvi_cadastral_plants
LEFT JOIN locations ON cvi_cadastral_plants.id = locations.localizable_id AND locations.localizable_type = 'CviCadastralPlant'
LEFT JOIN lexicon.registered_postal_zones ON locations.registered_postal_zone_id = registered_postal_zones.id
LEFT JOIN lexicon.registered_vine_varieties AS vine_varieties  ON cvi_cadastral_plants.vine_variety_id = vine_varieties.id
LEFT JOIN lexicon.registered_vine_varieties AS rootstocks ON cvi_cadastral_plants.rootstock_id = rootstocks.id
LEFT JOIN lexicon.registered_protected_designation_of_origins AS designation_of_origins ON cvi_cadastral_plants.designation_of_origin_id = designation_of_origins.id;

DROP VIEW IF EXISTS formatted_cvi_cultivable_zones;

CREATE OR REPLACE VIEW formatted_cvi_cultivable_zones AS

SELECT ccz.name, 
	ccz.id,
	string_agg(
		DISTINCT(
			CASE 
				WHEN land_parcel_number IS NULL THEN section || work_number
				ELSE section || work_number ||'-' || land_parcel_number  
			END
			),', '
		) AS cadastral_references,
	INITCAP(string_agg(DISTINCT city_name,', ' ORDER BY city_name)) AS communes,
	ccz.cvi_statement_id,
	area_formatted(ccz.calculated_area_value) AS formatted_calculated_area,
	area_formatted(ccz.declared_area_value) AS formatted_declared_area,
	area_formatted(COALESCE(clp.calculated_area_value, ccz.calculated_area_value)) AS cvi_land_parcels_calculated_area,
	land_parcels_status
FROM cvi_cultivable_zones ccz
LEFT JOIN ( SELECT cvi_cultivable_zone_id, SUM(cvi_land_parcels.calculated_area_value) as calculated_area_value
       FROM cvi_land_parcels
       GROUP BY cvi_land_parcels.cvi_cultivable_zone_id
     ) AS clp
ON ccz.id = clp.cvi_cultivable_zone_id 
LEFT JOIN locations as locations ON ccz.id = locations.localizable_id AND locations.localizable_type = 'CviCultivableZone'
LEFT JOIN cvi_cadastral_plants ccp ON ccz.id = ccp.cvi_cultivable_zone_id
LEFT JOIN lexicon.registered_postal_zones ON locations.registered_postal_zone_id = registered_postal_zones.id
GROUP BY ccz.id, ccz.name, clp.calculated_area_value;

DROP VIEW IF EXISTS formatted_cvi_land_parcels;

CREATE OR REPLACE VIEW formatted_cvi_land_parcels AS
SELECT 
	cvi_land_parcels.id AS id,
	cvi_land_parcels.name,
	INITCAP(string_agg(DISTINCT city_name,', ' ORDER BY city_name)) AS communes,
	INITCAP(string_agg(DISTINCT locality,', ' ORDER BY locality)) AS localities,
	COALESCE(planting_campaign,'9999') planting_campaign,
	
	product_human_name_fra AS designation_of_origin_name,
	vine_varieties.short_name AS vine_variety_name,
	INITCAP(rootstocks.short_name) AS rootstock,

	declared_area_value,
	calculated_area_value,
	area_formatted(declared_area_value) AS declared_area_formatted,
	area_formatted(calculated_area_value) AS calculated_area_formatted,
	inter_vine_plant_distance_value :: int AS inter_vine_plant_distance_value,
	inter_row_distance_value :: int AS inter_row_distance_value,
	state,

	(CASE WHEN activities.name IS NULL THEN
		'not_defined'
    ELSE
    	activities.name
    END) as activity_name,

	cvi_cultivable_zone_id
	
FROM cvi_land_parcels
LEFT JOIN locations as locations ON cvi_land_parcels.id = locations.localizable_id AND locations.localizable_type = 'CviLandParcel'
LEFT JOIN activities ON cvi_land_parcels.activity_id = activities.id
LEFT JOIN lexicon.registered_vine_varieties AS rootstocks ON cvi_land_parcels.rootstock_id = rootstocks.id
LEFT JOIN lexicon.registered_postal_zones ON locations.registered_postal_zone_id = registered_postal_zones.id
LEFT JOIN lexicon.registered_vine_varieties AS vine_varieties  ON cvi_land_parcels.vine_variety_id = vine_varieties.id
LEFT JOIN lexicon.registered_protected_designation_of_origins AS designation_of_origins ON cvi_land_parcels.designation_of_origin_id = designation_of_origins.id
GROUP BY cvi_land_parcels.id, designation_of_origin_name, vine_variety_name, rootstock, activities.name;
