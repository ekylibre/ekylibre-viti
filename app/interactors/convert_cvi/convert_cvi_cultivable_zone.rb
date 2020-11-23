module ConvertCvi
  class ConvertCviCultivableZone
    def initialize(cvi_cultivable_zone)
      @cvi_cultivable_zone = cvi_cultivable_zone
    end

    def self.call(cvi_cultivable_zone)
      new(cvi_cultivable_zone).call
    end

    def call
      cultivable_zones = find_matching_cultivable_zones
      if cultivable_zones.any?
        cultivable_zones.first
      else
        create_cultivable_zone
      end
    end

    private

    attr_accessor :cvi_cultivable_zone

    def create_cultivable_zone
      CultivableZone.create_with(
        name: cvi_cultivable_zone.name,
        description: "Convert from CVI ID : #{cvi_cultivable_zone.cvi_statement_id}",
        shape: cvi_cultivable_zone.shape
      ).find_or_create_by(name: cvi_cultivable_zone.name)
    end

    def find_matching_cultivable_zones
      # check if cvi cz shape covered existing cz shape with 95 to 98% accuracy
      cvi_cz_shape = cvi_cultivable_zone.shape
      # check if cover at 95%
      cvi_cz_inside_cultivable_zone = CultivableZone.shape_covering(cvi_cz_shape, 0.05)
      if cvi_cz_inside_cultivable_zone.any?
        cvi_cz_inside_cultivable_zone
      else
        # check if match at 95%
        CultivableZone.shape_matching(cvi_cz_shape, 0.05)
      end
    end
  end
end
