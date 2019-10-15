module Shaped
  extend ActiveSupport::Concern
  include Shaped::Validity
  include Shaped::Cache

  included do
    scope :in_bounding_box, lambda { |bounding_box|
      where("#{self.table_name}.shape && ST_MakeEnvelope(#{bounding_box})")
    }
  end

  def shape
    Charta.new_geometry(self[:shape])
  end

  def shape_changed?
    Charta.new_geometry(shape_was) != shape
  end

  def surface_area(unit = :hectare)
    surface.in(:square_meter).convert(unit)
  end
end
