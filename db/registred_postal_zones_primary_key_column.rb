
Ekylibre::Tenant.list.each do |tenant|
  ActiveRecord::Base.connection.execute(
    "UPDATE \"#{tenant}\".locations
    SET registered_postal_zone_id = registered_postal_zones.id
    FROM lexicon.registered_postal_zones AS registered_postal_zones 
    WHERE locations.registered_postal_zone_id = registered_postal_zones.code"
  )
end