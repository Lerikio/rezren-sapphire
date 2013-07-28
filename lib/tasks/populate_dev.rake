# encoding : UTF-8
namespace :populate_dev do

	desc "Crée des instances de tous les modèles et leur dépendance"
	task "all" => :environment do
		ActiveRecord::Base.transaction do
			Rake::Task["populate_dev:architecture"].invoke
			Rake::Task["populate_dev:adherent"].invoke
			Rake::Task["populate_dev:admin"].invoke
		end
	end

	desc "Crée toute l'architecture"
	task "architecture" => :environment do
		ActiveRecord::Base.transaction do
			Rake::Task["populate:rooms"].invoke
			Rake::Task["populate:switches"].invoke
			Rake::Task["populate_dev:vlan"].invoke
		end
	end

	desc "Crée un VLAN"
	task "vlan" => :environment do
		require 'highline/import'

		vlan = Vlan.new
		vlan.number = ask('VLAN number:')
		vlan.name = ask('VLAN name:')
		vlan.save!

		unless Port.all == nil
			Port.all.each do |port|
				vlan.ports << port
			end
		end

	end

	desc "Crée un adhérent et son premier ordinateur"
	task "adherent" => :environment do

		require 'highline/import'

		adherent = Adherent.new
		adherent.full_name = "Jean Dupont"
		adherent.email = "jean.dupont@rezren.fr"
		adherent.password = "mdpTest"
		adherent.username = "jean.dupont"

		credit = adherent.build_credit

		computer = adherent.computers.build
		computer.mac_address = "00:00:00:00:00"

		dns_entry = computer.build_computer_dns_entry(name: "jean.dupont")

		dns_alias = dns_entry.alias_dns_entries.build(name: "thefirstcomp")

		unless Room.all = nil
			adherent.room = Room.first
			room = adherent.room
			room.port = Port.first
			room.save!
		end

		credit.save!
		computer.save!
		dns_entry.save!
		adherent.save!

	end

	desc "Crée un administrateur"
	task "admin" => :environment do

		require 'highline/import'

		begin

		    admin = Admin.new
		    admin.username = ask("Admin Username:")

		    begin
		      password = ask("Admin Password:") {|q| q.echo = false}
		      password_confirmation = ask("Repeat password:") {|q| q.echo = false}

		    end while password != password_confirmation

		    admin.password = password
		    saved = admin.save!

		    unless saved
		    	puts admin.errors.full_messages.join("\n")
		    	next
		    end

		end while !saved
	end

end