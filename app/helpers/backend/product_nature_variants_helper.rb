# == License
# Ekylibre - Simple agricultural ERP
# Copyright (C) 2008-2013 Brice Texier
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

module Backend
  module ProductNatureVariantsHelper
    def quantity_to_receive(product_nature_variant)
      quantity = product_nature_variant.purchase_items.joins(:purchase).where("purchases.state = 'opened' AND purchases.type = 'PurchaseOrder'").map(&:quantity_to_receive).map(&:to_f).sum
      unit_name = product_nature_variant.unit_name
      "#{quantity} #{unit_name}"
    end
  end
end
