require 'test_helper'

class FormattedCviLandParcel < ActiveSupport::TestCase
  should enumerize(:state).in(:planted, :removed_with_authorization).with_predicates(true)
end
