# encoding : UTF-8
#
# ----------------------------------------------------------------------------------------------------------------
#
# Regénération des fichiers de conf DHCP
#
# ----------------------------------------------------------------------------------------------------------------
namespace :regenerate do
	require "dhcp_conf/dhcp_conf"
	require 'net/scp'
	require 'net/ssh'

	desc "Création du fichier DHCP pour les supélecs"
	task :supelec_dhcp => :environment do
		File.open("#{Rails.root}/tmp/hosts_supelec.conf",'w+') do |f|
			f.write(DhcpConf.new(Computer.supelec).output)
		end
	end

	desc "Création du fichier DHCP pour les non supélecs"
	task :others_dhcp => :environment do
		File.open("#{Rails.root}/tmp/hosts_others.conf",'w+') do |f|
			f.write(DhcpConf.new(Computer.others).output)
		end
	end

	desc "Upload des fichiers sur le serveur"
	task :upload_dhcp => :environment do
		lemuria_password = "PlsFindAWayToPutPasswordHere"
		Net::SCP.upload!("10.2.0.3", "sapphire",
			"#{Rails.root}/tmp/hosts_supelec.conf", "/tmp/hosts_supelec.conf",
			:password => lemuria_password)
		Net::SCP.upload!("10.2.0.3", "sapphire",
			"#{Rails.root}/tmp/hosts_others.conf", "/tmp/hosts_others.conf",
			:password => lemuria_password)
		Net::SSH.start('10.2.0.3', 'sapphire', :password => lemuria_password) do |ssh|
			ssh.exec("/home/sapphire/scripts/reload_dhcp.sh")
		end
	end

	desc "Génération des fichiers et upload sur le serveur"
	task :dhcp_all => :environment do
		Rake::Task["regenerate:supelec_dhcp"].invoke
		Rake::Task["regenerate:others_dhcp"].invoke
		Rake::Task["regenerate:upload_dhcp"].invoke
	end

end