# -*- encoding : utf-8 -*-
class VlanConnection < ActiveRecord::Base

# Permet l'attribution d'un VLAN à un port.
# Le booléen tagged caractériste cette relation.

	belongs_to :port, inverse_of: :vlan_connections

# Chaque port ne peut avoir qu'une seule connection par VLAN, et le vlan doit concorder avec config/initializers/VLAN.rb
	validates :vlan, presence: true, uniqueness: {scope: :port_id}, inclusion: {in: VLAN::List}
	validates :port, presence: true

end
