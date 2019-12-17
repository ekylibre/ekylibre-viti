class Location < Ekylibre::Record::Base
    belongs_to :localizable, polymorphic: true
    belongs_to :registered_postal_zone, foreign_key: :insee_number
end
