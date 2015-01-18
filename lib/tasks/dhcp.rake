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
	task :refresh_file_dhcp => :environment do
		File.open("#{Rails.root}/tmp/hosts_dhcp.conf",'w+') do |f|
			f.write(DhcpConf.new(Computer.supelec).output)
			f.write(DhcpConf.new(Computer.others).output)
		end
	end

	desc "Upload des fichiers sur le serveur"
	task :upload_dhcp => :environment do
		lemuria_password = Passwords::Lemuria
		Net::SCP.start("10.2.0.2", "sapphire", :password => lemuria_password) do |scp|
			scp.upload! "#{Rails.root}/tmp/hosts_dhcp.conf", "/etc/dhcp/users.conf"
		end
		Net::SSH.start('10.2.0.2', 'sapphire', :password => lemuria_password) do |ssh|
			ssh.exec("sudo service isc-dhcp-server restart")
		end
	end

	desc "Génération des fichiers et upload sur le serveur"
	task :dhcp_all => :environment do
		Rake::Task["regenerate:refresh_file_dhcp"].invoke
		Rake::Task["regenerate:upload_dhcp"].invoke
	end
end
