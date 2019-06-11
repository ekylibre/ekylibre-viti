module Ekylibre
  # Import a list of cultivable zone from georeadings
  # Prefer ekylibre/cultivable_zones_json to import directly cultivable zones
  # REMOVEME This exchanger is not very useful in standalone mode
  class CultivableZonesExchanger < ActiveExchanger::Base
    DEFAULT_SHAPE = Charta.new_geometry('MULTIPOLYGON(((0 0,0 1,1 1,1 0,0 0)))').freeze

    def find_zone_by_matching_shape(shape)
      CultivableZone.shape_covering(shape, 0.02).first || CultivableZone.shape_matching(shape, 0.02).first
    end
        
    def find_or_init_by_number(work_number)
      CultivableZone.find_or_initialize_by(work_number: work_number)
    end

    # Create or updates cultivable zones
    def import
      rows = CSV.read(file, headers: true).delete_if { |r| r[0].blank? }
      w.count = rows.size

      rows.each do |row|
        r = {
          name: (row[0].blank? ? nil : row[0].to_s),
          nature: (row[1].blank? ? nil : row[1].to_sym),
          code: (row[2].blank? ? nil : row[2].to_s),
          georeading_number: (row[3].blank? ? nil : row[3].to_s),
          soil_nature: (row[4].blank? ? nil : row[4].to_sym),
          owner_name: (row[5].blank? ? nil : row[5].to_s),
          farmer_name: (row[6].blank? ? nil : row[6].to_s)
        }.to_struct

        # check if existing CultivableZone cover or overlap a current object to import
        georeading = Georeading.find_by(number: r.georeading_number) ||
                     Georeading.find_by(name: r.georeading_number)
        default_zone = find_or_init_by_number(r.code)
        
        if georeading
          shape = georeading.content
          zone = find_zone_by_matching_shape(shape)&.tap { |z| z.shape = shape }
          zone ||= default_zone.tap { |z| z.shape = shape }
        end

        Rails.logger.warn "Cannot find georeading: #{r.georeading_number}" unless zone
        zone ||= default_zone.tap { |z| z.shape = DEFAULT_SHAPE.dup }

        # update name & code anyway
        zone.name = r.name if r.name
        zone.work_number = r.code if r.code
        if r.soil_nature && Nomen::SoilNature[r.soil_nature]
          zone.soil_nature ||= r.soil_nature
        end

        # link or update the owner if exist
        if r.owner_name
          owner = Entity.find_by('full_name ILIKE ?', r.owner_name.strip)
          zone.owner ||= owner if owner
        end

        # link or update the farmer if exist
        if r.farmer_name
          farmer = Entity.find_by('full_name ILIKE ?', r.farmer_name.strip)
          zone.farmer ||= farmer if farmer
        end

        zone.save!
        w.check_point
      end
    end
  end
end
