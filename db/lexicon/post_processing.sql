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

    ha_area = to_char(ha_area_num , 'FM00');
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
	commune,
	locality,
	
	CASE 
	  WHEN land_parcel_number IS NULL THEN 
	    CONCAT(section,' ', work_number)
	  ELSE
	   CONCAT(section,' ', work_number,'-',land_parcel_number ) 
	END AS cadastral_reference,
	
	designation_of_origins.product_human_name_fra AS designation_of_origin_name,
	INITCAP(vine_varieties.specie_name) AS vine_variety_name,
	area_value,
	area_formatted(area_value) AS area_formatted,
	campaign,

	CASE 
	  WHEN rootstock_id IS NULL THEN 
	    NULL	
	  ELSE
	   INITCAP(rootstocks.specie_name)
	END AS rootstock,
	
	inter_vine_plant_distance_value :: int AS inter_vine_plant_distance_value,
	inter_row_distance_value :: int AS inter_row_distance_value,
	state,
	
	cvi_statement_id
	
FROM cvi_cadastral_plants
LEFT JOIN lexicon.master_vine_varieties AS vine_varieties  ON cvi_cadastral_plants.vine_variety_id = vine_varieties.id
LEFT JOIN lexicon.master_vine_varieties AS rootstocks ON cvi_cadastral_plants.rootstock_id = rootstocks.id
LEFT JOIN lexicon.registred_protected_designation_of_origins AS designation_of_origins ON cvi_cadastral_plants.designation_of_origin_id = designation_of_origins.ida;

DROP VIEW IF EXISTS formatted_cvi_land_parcels;

CREATE OR REPLACE VIEW formatted_cvi_land_parcels AS
SELECT 
	cvi_land_parcels.id AS id,
	name,
	commune,
	locality,
	
	designation_of_origins.product_human_name_fra AS designation_of_origin_name,
	INITCAP(vine_varieties.specie_name) AS vine_variety_name,

	declared_area_value,
	calculated_area_value,
	area_formatted(declared_area_value) AS declared_area_formatted,
	area_formatted(calculated_area_value) AS calculated_area_formatted,
	inter_vine_plant_distance_value :: int AS inter_vine_plant_distance_value,
	inter_row_distance_value :: int AS inter_row_distance_value,
	state,

	CASE 
	  WHEN rootstock_id IS NULL THEN 
	    NULL	
	  ELSE
	   INITCAP(rootstocks.specie_name)
	END AS rootstock,
	cvi_cultivable_zone_id
	
FROM cvi_land_parcels
LEFT JOIN lexicon.master_vine_varieties AS vine_varieties  ON cvi_land_parcels.vine_variety_id = vine_varieties.id
LEFT JOIN lexicon.master_vine_varieties AS rootstocks ON cvi_land_parcels.rootstock_id = rootstocks.id
LEFT JOIN lexicon.registred_protected_designation_of_origins AS designation_of_origins ON cvi_land_parcels.designation_of_origin_id = designation_of_origins.ida