class FormattedCviLandParcel < ApplicationRecord
  enumerize :state, in: %i[planted removed_with_authorization], predicates: true
end
