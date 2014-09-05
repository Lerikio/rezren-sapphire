# encoding: utf-8

#---------------------------------------------------------------
# JuniperNetconfInterface
#
# Bibliothèque offrant les fonctions de base permettant de manager un switch juniper via netconf
#
# Adrien THIERRY 2014
#---------------------------------------------------------------

module JuniperNetconfInterface
	require 'net/netconf'

	#---------------------------------------------
	# Connexion à un switch
	#
	# - ip (string)
	# - username (string)
	# - password (string)
	#
	# Renvoie un objet représentant la session SSH
	# pour les autres fonctions
	#---------------------------------------------
	def connection(ip, username, password)
		# Informations de login
		login = { :target => ip, :username => username, :password => password }
		
		# Création d'une session ssh avec le switch
		puts "Connexion SSH au switch..."
		session = Netconf::SSH.new(login)
		if (session.open) # Réussite d'ouverture de la session
			puts "Session ouverte"
		else # Echec
			puts "Echec de l'ouverture de la session"
		end
		
		# On retourne la session SSH pour qu'elle puisse être utilisée par d'autres fonctions
		return session
	end

	#---------------------------------------------
	# Connexion à un switch
	#
	# - session (Objet de session SSH)
	#---------------------------------------------
	def deconnexion(session)
		puts "Fermeture de la connexion SSH avec le switch..."
		
		if (session.close) # Réussite de fermeture de la session
			puts "Session fermée"
		else # Echec
			puts "Echec de la fermeture de la session"
		end
	end

	#---------------------------------------------
	# Mapping nom du vlan / numéro du vlan
	#
	# - session (Objet de session SSH)
	#
	# Renvoie un hash de hash
	#---------------------------------------------
	def get_mapping_vlans(session)
		# Récupération de la config entière du switch dans une variable
		# get_config est l'une des méthodes de netconf
		inv = session.rpc.get_config

		vlans = inv.xpath("configuration/vlans/vlan")

		tableau_a_retourner = Array.new
		
		vlans.each_with_index do |vlan, i|
			hash_a_retourner {
		end

		puts vlans
	end


	#---------------------------------------------
	# Obtention de la config des ports
	#
	# - session (Objet de session SSH)
	#
	# Renvoie un hash {:numero_port, :numero_vlan,
	# :macs_autorisees }
	#---------------------------------------------
	def get_ports_config(session)
		# Récupération de la config entière du switch dans une variable
		# get_config est l'une des méthodes de netconf
		inv = session.rpc.get_config

		puts inv
	end
end
