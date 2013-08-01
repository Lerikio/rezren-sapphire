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

		credit = Credit.new
		adherent.credit = credit

		computer = Computer.new
		computer.mac_address = "00:00:00:00:00:00"
		adherent.computers << computer


		dns_entry = ComputerDnsEntry.new :name => "jean.dupont"
		computer.computer_dns_entry = dns_entry

		dns_alias = AliasDnsEntry.new :name => "thefirstcomp"
		dns_entry.alias_dns_entries << dns_alias

		unless Room.all == []
			Room.first.adherent = adherent
			room = adherent.room
			room.port = Port.first
			room.save!
		end

		adherent.save!
		credit.save!
		computer.save!
		dns_entry.save!
		dns_alias.save!

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