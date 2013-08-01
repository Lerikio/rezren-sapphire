# -*- encoding : utf-8 -*-
class VlanConnection < ActiveRecord::Base

# Il s'agit de la classe d'association entre VLAN et Ports de switchs.
# Le booléen tagged caractériste cette relation.

	belongs_to :port, inverse_of: :vlan_connections

	validates :vlan, presence: true, :uniqueness => {scope: :port_id}, :inclusion => {in: VLAN::List}
	validates :port, presence: true

end
