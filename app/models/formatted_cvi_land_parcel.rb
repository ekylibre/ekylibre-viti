class FormattedCviLandParcel < Ekylibre::Record::Base
  enumerize :state, in: %i[planted removed_with_authorization], predicates: true
end
