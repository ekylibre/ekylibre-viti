module Shaped
  module Validity
    extend ActiveSupport::Concern
    include Shaped::Validity::Intersections

    included do
      before_validation :clean_up_shape!

      validate do
        errors.add(:shape, :invalid) unless has_valid_shape?
        next if total_intersection_area <= allowed_intersection_area
        intersections.each do |kind, _, _|
          errors.add kind, :intersects
        end
      end
    end

    def has_valid_shape?
      is_shape_valid = self.class.connection.execute(<<~SQL)
        SELECT ST_IsValid(ST_GeomFromEWKT('#{self.shape.to_ewkt}')) AS valid_shape
      SQL
      is_shape_valid[0]['valid_shape']
    end

    def clean_up_shape!
      return unless make_shape_valid!
      clean_up_minor_intersections!
      update_allowed_intersection!
    end

    def make_shape_valid!
      new_shape = ShapeValidator.make_valid(shape)
      return self.shape = new_shape if new_shape
      false
    end
  end
end
