# encoding : UTF-8
#
# ----------------------------------------------------------------------------------------------------------------
#
# Script de payement des adhérents
#
# ----------------------------------------------------------------------------------------------------------------
namespace :payments do

	desc "Script de payement des adhérents"
	task :debit_cotisation => :environment do
		Adherent.not_archived.each do |a|
			a.credit.debit_cotisation
		end
	end

	desc "Script initial de calcul des dates"
	task :init_dates => :environment do
		Adherent.not_archived.each do |a|
			a.credit.next_debit = 1.month.from_now
			a.credit.update_end_of_adhesion
		end
	end

end