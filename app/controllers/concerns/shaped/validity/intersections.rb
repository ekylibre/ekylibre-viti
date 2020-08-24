module Shaped
  module Validity
    module Intersections
      extend ActiveSupport::Concern
      AREA_PRECISION = 4
      MAX_CLEANUP_TRIES = 30

      CHANGE_AREA_THRESHOLD = ShapeValidator::CHANGE_AREA_THRESHOLD
      CHANGE_PERCENTAGE_THRESHOLD = ShapeValidator::CHANGE_PERCENTAGE_THRESHOLD

      def clean_up_minor_intersections!(max_area: CHANGE_AREA_THRESHOLD,
                                        max_change_perc: CHANGE_PERCENTAGE_THRESHOLD)
        shape_cleaned = false
        tries = 0
        until shape_cleaned do
          # puts tries.to_s.yellow
          break if tries > MAX_CLEANUP_TRIES
          to_clean_up = intersections.select do  |_, _, area|
            percentage_of_change = area / self.shape.area * 100
            percentage_of_change < max_change_perc && area < max_area
          end

          shape_cleaned = true unless to_clean_up.any?

          table = self.class.table_name
          new_shape = to_clean_up.reduce(self.shape.to_ewkt) do |shape, (_, record_id, _)|
            self.class.where(id: record_id).select(:farm_id, <<~SQL).first[:ewkt]
              ST_AsEWKT(ST_Difference(ST_MakeValid(ST_GeomFromEWKT('#{shape}')),
                                      ST_BUFFER(#{table}.shape, 0.0000001))) AS ewkt
            SQL
          end
          unless new_shape = ShapeValidator.make_valid(new_shape)
            break false
          end
          tries += 1
          self.shape = new_shape
        end
      end

      def intersections
        return [] if self.shape.empty?
        table = self.class.table_name
        records = self.class.where(farm_id: self.farm_id)
                            .where.not(id: self.id)
                            .select(:farm_id, <<~SQL)
          id AS intersecting_record_id,
          ST_AREA(ST_INTERSECTION(ST_GeomFromEWKT('#{self.shape.to_ewkt}'),
                                  #{table}.shape)::geography) AS intersection_area,
          ST_TOUCHES(ST_GeomFromEWKT('#{self.shape.to_ewkt}'),
                     #{table}.shape) AS touches,
          ST_EQUALS(ST_GeomFromEWKT('#{self.shape.to_ewkt}'),
                    #{table}.shape) AS equals
        SQL

        records.map do |r|
          intersection_exists = r[:intersection_area].nonzero?
          intersects = intersection_exists && !r[:touches]
          same_shape = r[:equals]
          next [:base, r[:intersecting_record_id], r[:intersection_area]] if same_shape
          next [:shape, r[:intersecting_record_id], r[:intersection_area]] if intersects
          nil
        end.compact
      end

      def total_intersection_area(precision: AREA_PRECISION)
        # TODO: Replace with a query as in migration
        BigDecimal.new(intersections.sum(&:last).to_s)
          .truncate(precision).in(:square_meter)
      end

      def intersection_allowed(precision: AREA_PRECISION)
        BigDecimal.new((self[:intersection_allowed] || 0).to_s).in(:square_meter)
      end
      alias allowed_intersection_area intersection_allowed

      private

      def update_allowed_intersection!
        return unless total_intersection_area <= allowed_intersection_area
        # As soon as intersection area lessens, restrict intersection allowed
        self.intersection_allowed = total_intersection_area
      end
    end
  end
end
