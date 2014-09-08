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
	# à passer aux autres fonctions
	#---------------------------------------------
	def connexion(ip, username, password)
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
	# Renvoie un hash :
	# {:nom_vlan_0 => :id_vlan_0, :nom_vlan_1 => ...}
	#---------------------------------------------
	def get_mapping_vlans(session)
		# Récupération de la config entière du switch dans une variable
		# get_config est l'une des méthodes de netconf
		
		inv = session.rpc.get_config

		vlans = inv.xpath("configuration/vlans/vlan")		

		hash = Hash.new

		@id_courant = nil
		@nom_courant = nil
		@vlan_id_present = false

		vlans.each do |vlan|
			# Premier passage dans la liste des enfants pour voir si la balise vlan-id est présent
			@vlan_id_present = false
			vlan.children.each do |child|
				if (child.to_s.include? "vlan-id")
					@vlan_id_present = true
				end
			end
			
			if @vlan_id_present
				vlan.children.each do |child|
					if (child.to_s.include? "name")
						@nom_courant = child.content
					elsif (child.to_s.include? "vlan-id")
						@id_courant = child.content
					end
				end

			else # Sinon c'est que c'est le vlan default
				@id_courant = "0"
				@nom_courant = "default"
			end
			
			# Ajout du VLAN au hash
			hash[@nom_courant] = @id_courant
		end

		return hash
	end


	#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	#UNIQUEMENT POUR LES TESTS
	#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	def get_config(session)
		# Récupération de la config entière du switch dans une variable
		# get_config est l'une des méthodes de netconf
		inv = session.rpc.get_config

		puts inv
	end


	#---------------------------------------------
	# Obtention de la config des ports
	# On ne s'occupe que des ports managés par Sapphire,
	# qui sont en untagged (ou access)
	#
	# - session (Objet de session SSH)
	#
	# Renvoie un tableau de hash :
	# - indice du tableau = numéro du port
	# - {:admin_status => statut administratif (up ou down),
	# :vlan_id => id du untagged vlan du port,
	# :allowed_macs => [tableau des macs autorisées]}
	#
	# Toutes les valeurs du hash sont des string
	#---------------------------------------------
	def get_ports_config(session)
		# Récupération du mapping des VLANs
		mapping = get_mapping_vlans(session)		

		# Récupération de la config entière du switch dans une variable
		# get_config est l'une des méthodes de netconf
		inv = session.rpc.get_config
		
		tableau = Array.new # Tableau qu'on renvoie

		@numero = nil

		#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		# RECUPERATION DU STATUT ADMINISTRATIF DE TOUS LES
		# PORTS
		#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		interfaces = session.rpc.get_interface_information.xpath("physical-interface")

		@admin_status_courant = nil

		interfaces.each_with_index do |interface|
			#**********************************************			
			# Choix de la bonne case dans le tableau
			#**********************************************		
			nom = interface.xpath("name")
			if nom.children.first.to_s[1..7] == "ge-0/0/" # On ne s'occupe pas des ports fibre
				@numero = nom.children.first.to_s[8..9] # On ne récupère que le numéro effectif (sans le ge....)

				#**********************************************			
				# Récupération du statut
				#**********************************************	
				if interface.xpath("admin-status").children.first.to_s.include? "up"
					@admin_status_courant = true
				else
					@admin_status_courant = false
				end

				# Ajout au tableau
				tableau[@numero.to_i] = Hash.new
				tableau[@numero.to_i][:admin_status] = @admin_status_courant
			end
		end
					
		#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		# RECUPERATION DU VLAN DE TOUS LES PORTS
		#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		@nom_courant = nil # Nom du VLAN du port
		@id_courant = nil # ID du VLAN du port
		@macs_courantes = nil # Macs autorisées sur le port
		@numero = nil

		ports = inv.xpath('configuration/interfaces/interface') # Partie de la conf qui nous intéresse

		ports.each do |port|
			
			#**********************************************			
			# Choix de la bonne case dans le tableau
			#**********************************************		
			nom = port.xpath("name")
			if nom.children.first.to_s[0..6] == "ge-0/0/" # On ne s'occupe pas des ports fibre
				@numero = nom.children.first.to_s[7..8] # On ne récupère que le numéro effectif (sans le ge....)
			
				#**********************************************			
				# Récupération du VLAN
				#**********************************************
				vlan_params = port.xpath("unit/family/ethernet-switching")
				# 1er cas : ethernet-switching ne contient pas d'info sur le port mode. Alors le VLAN est 0
				if (vlan_params.xpath("port-mode").to_s == "")
					@nom_courant = "default"			
					@id_courant = 0

				# 2eme cas : le port est en trunk. On met nil pour l'id courant et "trunk"
				# pour le nom du vlan
				else
					vlan_mode = vlan_params.xpath("port-mode").children.first.to_s
					if (vlan_mode != "access")
						@nom_courant = "trunk"
						@id_courant = -1
			
				# 3eme cas : le port est en access. On récupère son vlan
					else
						vlan = vlan_params.xpath("vlan/members").children.first.to_s
						@nom_courant = vlan
						@id_courant = mapping[@nom_courant].to_i
					end
				end

				# Remplissage du tableau avec le vlan du port actuel
				tableau[@numero.to_i][:vlan_id] = @id_courant
			end

		end

		#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		# RECUPERATION DES MACS AUTORISEES SUR CHAQUE PORT
		#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		secure_interfaces = inv.xpath("configuration/ethernet-switching-options/secure-access-port/interface")

		secure_interfaces.each do |interface|
			@macs_courantes = Array.new
			#**********************************************			
			# Choix de la bonne case dans le tableau
			#**********************************************		
			nom = interface.xpath("name")
			if nom.children.first.to_s[0..6] == "ge-0/0/" # On ne s'occupe pas des ports fibre
				@numero = nom.children.first.to_s[7..8] # On ne récupère que le numéro effectif (sans le ge....)
				if @numero[1] == '.'
					@numero = @numero[0]
				end

				#**********************************************			
				# Récupération des macs
				#**********************************************
				macs = interface.xpath("allowed-mac")
				macs.each do |mac|
					@macs_courantes.push(mac.children.first.to_s)
				end

			# Remplissage du tableau final avec les macs
			tableau[@numero.to_i][:allowed_macs] = @macs_courantes

			end
		
		end

		# Ajout d'un tableau vide pour les ports qui n'ont pas de mac autorisée
		tableau.length.times do |i|
			if tableau[i][:allowed_macs] == nil
				tableau[i][:allowed_macs] = Array.new
			end
		end

		return tableau

	end


	#---------------------------------------------
	# Modification de la config des ports
	#
	# - session (Objet de session SSH)
	# - config (tableau du même type que celui renvoyé
	# par get_ports_config
	#---------------------------------------------
	def set_ports_config(session, config)

		xml = Nokogiri::XML::Builder.new {|xml| xml.configuration {
			config.length.times do |i| 
      	if(config[i] != nil)      	
        	if(config[i][:admin_status] != nil)
    	    	xml.interfaces {
	    				xml.interface {
		    		  	xml.name "ge-0/0/#{i}"
			    			# Modification du statut administratif des ports
				    			if (config[i][:admin_status] == true)
					    	  	xml.enable;
					       	else
				    		   	xml.disable;
			    				end
		    			}
	    			}
					end

          if(config[i][:vlan_id] != nil)
        		xml.interfaces {
	    				xml.interface {
		    				# Modification du VLAN
			    	    xml.name "ge-0/0/#{i}"
			        	xml.unit {
		    		    	xml.name "0"
	    				    xml.family {
    						  	xml.send 'ethernet-switching' do
								   		xml.send :"port-mode", "access"
								    	xml.vlan {
							    			xml.members('operation' => 'delete')
						    				xml.members config[i][:vlan_id]
					    				}
    				    		end
	    		    		}						
		        		}
	    	    	}
    			  }
					end
					
					# Modification des macs
					if (config[i][:allowed_mac] != nil)
						xml.send('ethernet-switching-options') do
					  	xml.send('secure-access-port') do
								xml.interface {
									xml.name "ge-0/0/#{i}"

									# Macs à ajouter										
										config[i][:allowed_macs][:add].length.times do |j|
											xml.send :'allowed-mac', config[i][:allowed_macs][:add][j]
										end
												
									# Macs à enlever
										config[i][:allowed_macs][:del].length.times do |j|
											xml.send :'allowed-mac', config[i][:allowed_macs][:del][j], 'operation' => 'delete'
										end
								}
						  end   
						end     	
					end
				end
				end
    	}}

		#**********************************************			
		# Ecriture de la config
		#**********************************************
		session.rpc.lock 'candidate'

		session.rpc.edit_config(xml)
	end


	#---------------------------------------------
	# Commit de la config sur le switch
	#
	# - session (Objet de session SSH)
	#
	#---------------------------------------------
	def commit_config(session)
		if session.rpc.validate 'candidate'
		else
			puts "Erreur de syntaxe"
		end

		puts "Commit en cours..."

		if session.rpc.commit
			puts "Commit réussi"
		else
			puts "Echec lors du commit"
		end

		session.rpc.unlock 'candidate'	
	end
end
