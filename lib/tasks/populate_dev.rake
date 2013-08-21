# encoding : UTF-8
#
# ----------------------------------------------------------------------------------------------------------------
#
# Génération d'une base de donnée d'exemples pour le développement
#
# Script réalisé en août 2013 par Valérian Justine (Promo 2015)
#
# ----------------------------------------------------------------------------------------------------------------

namespace :populate_dev do

##################################################################################################################
#
#                                            =====> Attention <=====
#
#  							Ces scripts NE DOIVENT PAS être utilisés en production !
#
##################################################################################################################

# -----------------------------------------------------------------------------------------------------------------
# Appel de tous les scripts 
# -----------------------------------------------------------------------------------------------------------------

	desc "Crée des instances de tous les modèles et leur dépendance"
	task "all" => :environment do
		ActiveRecord::Base.transaction do
			Rake::Task["populate_dev:architecture"].invoke
			Rake::Task["populate_dev:adherent"].invoke
			Rake::Task["populate_dev:admin"].invoke
		end
	end


# -----------------------------------------------------------------------------------------------------------------
# Appel des scripts de populate.rake pour la génération de l'architecture
# -----------------------------------------------------------------------------------------------------------------

	desc "Crée toute l'architecture"
	task "architecture" => :environment do
		ActiveRecord::Base.transaction do
			Rake::Task["populate:rooms"].invoke
			Rake::Task["populate:switches"].invoke
		end
	end


# -----------------------------------------------------------------------------------------------------------------
# Génération d'un adhérent, et de toutes ses dépendances
# -----------------------------------------------------------------------------------------------------------------


	desc "Crée un adhérent et son premier ordinateur"
	task "adherent" => :environment do

		adherent = Adherent.new
		adherent.first_name = "Jean"
		adherent.last_name = "Dupont"
		adherent.email = "jean.dupont@rezren.fr"
		adherent.password = "mdpTest"
		adherent.username = "jean.dupont"
		adherent.promotion = Time.now.year
		adherent.resident = true
		adherent.supelec = true

		credit = Credit.new
		adherent.credit = credit

		computer = Computer.new
		computer.mac_address = "00:00:00:00:00:00"
		computer.name = Computer.generate_name(adherent.last_name)
		adherent.computers << computer


		dns_alias = AliasDnsEntry.new :name => "thefirstcomp"
		computer.alias_dns_entries << dns_alias

		room = Room.first
		room.adherent = adherent
		room.port = Port.first
		adherent.save!
		room.save!
		credit.save!
		computer.save!
		dns_alias.save!
	end


# -----------------------------------------------------------------------------------------------------------------
# Génération d'un premier administrateur 
# -----------------------------------------------------------------------------------------------------------------


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