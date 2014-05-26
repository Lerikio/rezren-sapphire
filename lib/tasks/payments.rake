# encoding : UTF-8
#
# ----------------------------------------------------------------------------------------------------------------
#
# Script de payement des adhérents
#
# ----------------------------------------------------------------------------------------------------------------
namespace :payments do

	desc "Script de calcul des dates"
	task :init_dates => :environment do
		Adherent.not_archived.each do |a|
			if a.credit
				a.credit.update_end_of_adhesion
				a.credit.save
			end
		end
	end

	desc "Initialisation de la valeur des cotisation de chaque paiement (si necessaire)"
	task :init_cotisation => :environment do
		Payment.all.each do |p|
			p.save_current_cotisation
		end
	end
end
