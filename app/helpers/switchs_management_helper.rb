# -*- encoding : utf-8 -*-
module SwitchsManagementHelper

	def ouverture_fenetre
		code = "
			<div class=\"modal-header\">
				<h3>Veuillez patienter</h3>
			</div>


			<div class=\"modal-body\">
  				<div class=\"progress progress-striped active\">
    					<div class=\"bar\" style=\"width: 100%;\"></div>
 				</div>
			</div>"

		return raw code

	end


	def synchronisation
		Switch.not_archived.each do |s|
			port_managed = 0
			s.ports.each do |p|
				if(p.managed == true)
					port_managed += 1
				end
			end
			if(port_managed > 0)
                #Etablissement de la connection au switch
                session = JuniperNetconfInterface::connexion(s.ip_admin, "root", Passwords::Juniper)

				#Configuration du switch
                JuniperNetconfInterface::set_ports_config(session, s.get_changes(JuniperNetconfInterface::get_ports_config(session)))
                
                puts "Commiting..."
				JuniperNetconfInterface::commit_config(session)
				JuniperNetconfInterface::deconnexion(session)
                puts "Disconnected."
			end
		end
	end

	def fermeture_fenetre
		code = "
		<script>$('#modal-window').modal('hide');</script>"

		return raw code
	end

	def synchronisation_affichage
		synchronisation
		fermeture_fenetre
	end
end
