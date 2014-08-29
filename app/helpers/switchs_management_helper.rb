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
				puts "Switch " + s.description
				session = s.connect_by_netconf
				s.ports.each do |p|
					p.update_vlans_by_netconf(session)
					p.update_mac_adresses_by_netconf(session)
				end
				s.commit_modifs_by_netconf(session)
				s.disconnect_by_netconf(session)
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
