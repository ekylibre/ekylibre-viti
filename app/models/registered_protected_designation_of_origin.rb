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
# == Table: registered_protected_designation_of_origins
#
#  eu_sign                :string
#  fr_sign                :string
#  geographic_area        :string
#  ida                    :integer          not null, primary key
#  product_human_name     :jsonb
#  product_human_name_fra :string
#  reference_number       :string
#
class RegisteredProtectedDesignationOfOrigin < ActiveRecord::Base
    self.primary_key = :id
    include Lexiconable
    has_many :cvi_cadastral_plants, foreign_key: :designation_of_origin_id
  end
