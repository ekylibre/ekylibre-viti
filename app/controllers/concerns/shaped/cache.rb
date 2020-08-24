module Shaped
  module Cache
    extend ActiveSupport::Concern

    included do
      before_validation :cache_geodata
    end

    private

    def cache_geodata
      return clear_geodata_cache unless shape.present?
      self.surface  = shape.area
      self.centroid = shape.to_rgeo.centroid
    end

    def clear_geodata_cache
      self.surface = nil
      self.centroid = nil
    end
  end
end
