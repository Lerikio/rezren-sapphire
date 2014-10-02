# encoding : UTF-8

namespace :mailing do

	desc "Création du fichier de mailing locale"
	task :generate_aliases => :environment do
		list = ""
		Adherent.not_archived.each do |a|
			list = list + a.email + ", "
		end

		File.open("#{Rails.root}/tmp/aliases_asso/adherents",'w+') do |f|
			f.write(list)
		end

		File.open("#{Rails.root}/tmp/aliases_asso/aliases",'w+') do |fmanager|
			file_asso = "adherents: :include:/etc/aliases_asso/adherents\n"
			Mailing.not_archived.each do |m|
				file_asso += m.name + ": :include:/etc/aliases_asso/" + m.name + "\n"

				list = ""
				m.emails.each do |t|
					list += t + ", "
				end
				File.open("#{Rails.root}/tmp/aliases_asso/" + m.name,'w+') do |f|
					f.write(list)
				end
			end
			fmanager.write(file_asso)
		end
	end

	desc "Envoi du fichier sur le asgard"
	task :synchro_asgard => :environment do
		Net::SCP.start("10.5.0.8", "sapphire", :password => Passwords::Asgard) do |scp|
			Mailing.not_archived.each do |m|
				scp.upload! "#{Rails.root}/tmp/aliases_asso/" + m.name, "/etc/aliases_asso/"
			end
			scp.upload! "#{Rails.root}/tmp/aliases_asso/adherents", "/etc/aliases_asso/"
			scp.upload! "#{Rails.root}/tmp/aliases_asso/aliases", "/etc/aliases_asso/"
		end
		Net::SSH.start('10.5.0.8', 'sapphire', :password => Passwords::Asgard) do |ssh|
			ssh.exec("sudo newaliases")
		end
	end

	desc "Synchroniser asgard et la BDD de Sapphire"
	task :synchronisation => :environment do
		Rake::Task["mailing:generate_aliases"].invoke
		Rake::Task["mailing:synchro_asgard"].invoke
	end
end
