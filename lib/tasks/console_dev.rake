#N'utiliser sous aucun pretexte

namespace :console do
        require 'highline/import'
        
	desc "Bidouillage d'urgence : changement d'ip"
	task :ip_change => :environment do
		mac = ask("Adresse mac :")
		new_ip = ask("Nouvelle adresse ip")
                Computer.not_archived.each do |c|
			if(c.mac_address == mac)
				c.ip_address = new_ip
				c.save
			end
                end
		#new_ip = ask("Nouvelle adresse ip") {|q| q.echo=false}
	end

	desc "Recherche d'ip"
        task :ip_lookup => :environment do
                ip = ask("Adresse ip")
                Computer.all.each do |c|
                        if(c.ip_address == ip)
                                puts c.mac_address
                        end
                end
                #new_ip = ask("Nouvelle adresse ip") {|q| q.echo=false}
        end
end
