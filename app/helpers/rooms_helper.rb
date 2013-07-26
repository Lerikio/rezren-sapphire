# -*- encoding : utf-8 -*-
module RoomsHelper

	# Liste des bâtiments pris en charge par l'application.
	# Les rajouter ici permet d'y avoir accès pour toutes les vues.
	def load_buildings
		@building_list = ['A', 'B', 'C', 'D', 'H']
	end

end
