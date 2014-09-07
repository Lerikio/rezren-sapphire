# encoding : utf-8

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

	desc "Script d'ajout d'une periode gratuite"
	task :add_free_period => :environment do
		admin = nil
		members = 0.to_f
		Admin.all.each do |a|
			if a.username == "igor" then
				admin = a
			end
		end
		puts "admin : " + admin.username

		Adherent.not_archived.each do |a|
			if a.credit != nil then
				members += 1
				p = a.credit.payments.new
				p.comment = "[Script][16082014] période offerte avant l'inté en attendant une gestion plus \"user friendly\" des rupture de connection"
				p.mean = "liquid"
				p.paid_value = 0
				p.value = 14.to_f*Credit::Monthly_cotisation/30
				p.cotisation = Credit::Monthly_cotisation
				p.admin = admin
				puts admin.username + " ajoute " + (14.to_f*Credit::Monthly_cotisation/30).to_s + " à " + a.full_name
				p.save!
			end
		end
		puts "il y a " + members.to_s + " membres"
	end

	desc "Script de suppression de paiement ajoute par script"
	task :del_free_period => :environment do
		Payment.all.each do |p|
			if p.comment.include?("[Script][16082014]") then
				puts "destroyed " + p.value.to_s + " belonging to " + p.adherent.full_name
				p.destroy
			end
		end
	end

	desc "Test netconf"
	task :test => :environment do
		s = Switch.find(2)
		session = s.connect_by_netconf
		if(session != nil)
			puts "Connection établie"
		else
			puts "Connection non établie."
		end
		
		port_status = s.ports.find_by_number(2).get_port_status(session)
		puts "Enabled : #{port_status[:enabled]}\n"
		puts "Vlan : #{port_status[:untagged_vlan_number]}"
		s.disconnect_by_netconf(session)
	end

	require "#{Rails.root}/app/helpers/switchs_management_helper"
	require "#{Rails.root}/lib/netconf_interface/juniper_netconf_interface"
	require 'net/netconf'

	include SwitchsManagementHelper 
	include JuniperNetconfInterface

	desc "Test synchronise"
	task :synchronise => :environment do
		synchronisation
	end

	desc "Crée une chambre"
	task :add_room => :environment do
		r = Room.new
        r.number = ask("Numéro de chambre:")
        r.building = ask("Bâtiment (ex. A):")
		r.save!
	end

    task :del_room => :environment do
        number = ask("Numéro de chambre:")
        building = ask("Bâtiment (ex. A):")

        Room.all.each do |r|
            if r.number.include?(number) && r.building.include?(building) then
                puts "destroyed " + r.building + " at " + r.number
                r.destroy
            end
        end
    end


	# Script pour tester la bibliothèque d'interface netconf
	desc "Tests netconf"
	task :tests_netconf => :environment do	
			session = connection("192.168.1.1", "root", "abc123")
			#puts get_config(session)

			tableau = Array.new
			hash = Hash.new
			hash[:admin_status] = "down"
			hash[:vlan] = "users"
			hash[:allowed_macs] = ["00:11:22:33:44:ab", "00:11:22:33:44:11"]
			
			tableau[0] = hash
			tableau[1] = hash
			tableau[2] = hash

			set_ports_config(session, tableau)

			puts get_ports_config(session)
			
			deconnexion(session)
	end
end
