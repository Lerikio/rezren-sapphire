# -*- encoding : utf-8 -*-
class Connexion < ActiveRecord::Base

# Il s'agit de la classe d'association entre VLAN et Ports de switchs.
# Le booléen tagged caractériste cette relation.

	belongs_to :vlan
	belongs_to :port

end
