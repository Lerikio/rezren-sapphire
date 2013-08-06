# encoding : UTF-8
#
# ----------------------------------------------------------------------------------------------------------------
#
# Génération de l'architecture générale du Rezo
#
# ----------------------------------------------------------------------------------------------------------------

namespace :populate do

##################################################################################################################
# 3 scripts																										 #
# => :rooms, pour générer les chambres																			 #
# => :switches, pour générer des switchs (attention, tous les mêmes)											 #
# => :ports, pour générer x ports pour un switch (attention, :switches appelent déjà :ports !)					 #
##################################################################################################################

# -----------------------------------------------------------------------------------------------------------------
# Génération des chambres 
# -----------------------------------------------------------------------------------------------------------------
	desc "Génère toutes les chambres existantes dans la configuration 2013 de la résidence de Rennes de Supélec"
	task :rooms => :environment do
		['A','B','C','D','H'].each do |building|

			unless building == 'H'

				# Tous les étages de 1 à 3 sont tous les mêmes
				for story in 1..3
					for number in 1..13
						if number < 10
							string_number = "0" + number.to_s
						else
							string_number = number.to_s
						end
						current_room = Room.new
						current_room.building = building
						current_room.number = story.to_s + string_number
						current_room.archived = false
						current_room.save(validate: false) # Evite les validations : normalement, une chambre devrait aussi avoir un port
					end
				end

				story = "0"
				unless building == 'B'
					for number in 1..12
						if number < 10
							string_number = "0" + number.to_s
						else
							string_number = number.to_s
						end
						current_room = Room.new
						current_room.building = building
						current_room.number = story + string_number
						current_room.archived = false
						current_room.save(validate: false) # Evite les validations : normalement, une chambre devrait aussi avoir un port
					end
				end
			end
		end
	end

# -----------------------------------------------------------------------------------------------------------------
# Génération des ports d'un switch 
# -----------------------------------------------------------------------------------------------------------------

	desc "Génère tous les ports d'un switch, en passant le switch et le nombre de port en entrée"
	task :ports, [:switch_id, :nbr_of_ports] => :environment do |t, args|

		for port_number in 1..args.nbr_of_ports.to_i

			current_port = Port.new
			current_port.switch_id = args.switch_id
			current_port.number = port_number
			vlan_connection = VlanConnection.new
			vlan_connection.port = current_port
			vlan_connection.vlan = VLAN::Supelec
			vlan_connection.save!
			current_port.save!

		end
	end


# -----------------------------------------------------------------------------------------------------------------
# Génération des switchs 
# -----------------------------------------------------------------------------------------------------------------

	desc "Génère des switchs TOUS SIMILAIRES en terme de nombre de ports, à partir du nombre de switches à créer et le nombre de port à leur attribuer.
		  Attention : il faudra définir l'IP et la community du switch à la main à travers l'interface web."
	task :switches => :environment do |t, args|

		require "highline/import"

	    nbr_of_switches = ask("Number of switches:")
	    nbr_of_ports = ask("Number of ports by switch:")

		for switch in 1..nbr_of_switches.to_i
			current_switch = Switch.new
			current_switch.community = "private"
			current_switch.ip_admin = "0.0.0.0"
			current_switch.save(validate: false)
			Rake::Task["populate:ports"].invoke(current_switch.id, nbr_of_ports)
			current_switch.save!(validate: false)
			
		end
	end

end