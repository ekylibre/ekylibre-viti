# = Informations
#
# == License
#
# Ekylibre - Simple agricultural ERP
# Copyright (C) 2008-2009 Brice Texier, Thibaud Merigon
# Copyright (C) 2010-2012 Brice Texier
# Copyright (C) 2012-2019 Brice Texier, David Joulin
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
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# == Table: purchases
#
#  accounted_at                             :datetime
#  affair_id                                :integer
#  amount                                   :decimal(19, 4)   default(0.0), not null
#  command_mode                             :string
#  confirmed_at                             :datetime
#  contract_id                              :integer
#  created_at                               :datetime         not null
#  creator_id                               :integer
#  currency                                 :string           not null
#  custom_fields                            :jsonb
#  delivery_address_id                      :integer
#  description                              :text
#  estimate_reception_date                  :datetime
#  id                                       :integer          not null, primary key
#  invoiced_at                              :datetime
#  journal_entry_id                         :integer
#  lock_version                             :integer          default(0), not null
#  nature_id                                :integer
#  number                                   :string           not null
#  ordered_at                               :datetime
#  payment_at                               :datetime
#  payment_delay                            :string
#  planned_at                               :datetime
#  pretax_amount                            :decimal(19, 4)   default(0.0), not null
#  quantity_gap_on_invoice_journal_entry_id :integer
#  reconciliation_state                     :string
#  reference_number                         :string
#  responsible_id                           :integer
#  state                                    :string           not null
#  supplier_id                              :integer          not null
#  tax_payability                           :string           not null
#  type                                     :string
#  undelivered_invoice_journal_entry_id     :integer
#  updated_at                               :datetime         not null
#  updater_id                               :integer
#
require 'test_helper'

class PurchaseOrderTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures

  test 'reconciliation_state is set correctly' do
    purchase_item = create :purchase_item, :of_purchase_order, quantity: 10
    reception_one = create(:reception)
    reception_item_one = create :reception_item, quantity: 5, variant: purchase_item.variant, purchase_order_item: purchase_item, reception: reception_one
    reception_item_one.reception.save!
    purchase_item.purchase.reload

    assert_equal 'to_reconcile', purchase_item.purchase.reconciliation_state

    reception_item_two = create :reception_item, purchase_order_item: purchase_item, quantity: 5, variant: purchase_item.variant, reception: reception_one
    reception_item_two.reception.reload
    reception_item_two.reception.save!

    purchase_item.purchase.reload
    reception_one.reload

    assert_equal 'reconcile', purchase_item.purchase.reconciliation_state

    reception_one.destroy
    purchase_item.purchase.reload

    assert_equal 'to_reconcile', purchase_item.purchase.reconciliation_state
  end
end
