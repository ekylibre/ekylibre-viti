
Ekylibre::Tenant.list.each do |tenant|
  ActiveRecord::Base.connection.execute(
    "UPDATE \"#{tenant}\".cvi_cadastral_plants AS ccp
    SET designation_of_origin_id = designation_of_origins.id
    FROM lexicon.registered_protected_designation_of_origins AS designation_of_origins
    WHERE ccp.designation_of_origin_id = designation_of_origins.ida"
  )
  ActiveRecord::Base.connection.execute(
    "UPDATE \"#{tenant}\".cvi_land_parcels AS clp
    SET designation_of_origin_id = designation_of_origins.id
    FROM lexicon.registered_protected_designation_of_origins AS designation_of_origins
    WHERE clp.designation_of_origin_id = designation_of_origins.ida"
    )
end