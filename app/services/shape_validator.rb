class ShapeValidator
  CHANGE_PERCENTAGE_THRESHOLD = 0.01
  CHANGE_AREA_THRESHOLD = 20

  def self.make_valid(shape)
    new(shape).valid_shape
  end

  def initialize(shape)
    @shape = Charta.new_geometry(shape)
  end

  def sql_shape
    "ST_GeomFromEWKT('#{@shape.to_ewkt}')"
  end

  def valid_shape
    return @shape if @shape.empty?
    original_area = @shape.area
    new_shape     = ActiveRecord::Base.connection.execute(validation_query).to_a.first
    new_shape     = Charta.new_geometry(new_shape['valid_shape'])
    new_area      = new_shape.area

    percentage_of_change = 100 - (new_area / original_area * 100)
    modified_area = new_area - original_area
    return false unless percentage_of_change.abs < CHANGE_PERCENTAGE_THRESHOLD &&
                        modified_area.abs < CHANGE_AREA_THRESHOLD
    new_shape
  end

  private

  def validation_query
    <<~SQL
      -- Get the nth-geometry inside a made-valid geometry
      CREATE OR REPLACE FUNCTION pg_temp.nth_geometry(geometry, int)
        RETURNS geometry AS $$
          SELECT ST_GeometryN(ST_CollectionExtract(ST_MakeValid($1), 3), $2)
        $$ LANGUAGE sql IMMUTABLE;

       -- Equivalent to a table with 1,2,3 ... 15 as values.
      WITH RECURSIVE geometry_indexes(n) AS (
        SELECT 1
          UNION ALL
        SELECT n + 1
          FROM geometry_indexes
         -- We're limiting to 15 since the max num of geometries we've seen in prod is 8.
          WHERE n < 15
      )
      SELECT pg_temp.nth_geometry(#{sql_shape}, n) AS valid_shape
      FROM geometry_indexes
        /* If the shape contains 3 geometries, we'll get:
                     new_shape
             <geometry 1 - 0.01% intersection>
             <geometry 2 - 99.9% intersection>
             <geometry 3 - 0.09% intersection>
        */
      WHERE pg_temp.nth_geometry(#{sql_shape}, n) IS NOT NULL
        /* The ORDER makes our earlier example become:
                     new_shape
             <geometry 2 - 99.9% intersection>
             <geometry 3 - 0.09% intersection>
             <geometry 1 - 0.01% intersection>
           And the LIMIT keeps only:
             <geometry 2 - 99.9% intersection>
        */
      ORDER BY ST_Area(ST_Intersection(ST_MakeValid(#{sql_shape}),
               pg_temp.nth_geometry(#{sql_shape}, n))::geography) DESC
      LIMIT 1;
    SQL
  end
end
