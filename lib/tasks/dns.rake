# encoding : UTF-8
#
# ----------------------------------------------------------------------------------------------------------------
#
# Regénération des zonefiles DNS 
#
# ----------------------------------------------------------------------------------------------------------------

namespace :regenerate do

##################################################################################################################
# => Ce namespace est utilisé dans d'autre fichier, en particulier dhcp.rake
# ----------------------------------------------------------------------------------------------------------------
#
# De nombreux scripts existent ici :
#
# =>   supelec_dns   &&   supelec_reverse_dns    pour le VLAN::Supelec
# =>     other_dns   &&   other_reverse_dns      pour le VLAN::Autre
# =>  external_dns   &&   external_reverse_dns   pour le DNS externe
# =>       all_dns                               qui appelle tous les autres scripts
#
##################################################################################################################

# -----------------------------------------------------------------------------------------------------------------
# Initialisation des constantes 
# -----------------------------------------------------------------------------------------------------------------

	Begining = "$ORIGIN example.com.     
				$TTL 1h                  
				example.com.  IN  SOA  ns.example.com. username.example.com. (
				              2007120710 
				              1d         
				              2h         
				              4w         
				              1h
				              )"	

# -----------------------------------------------------------------------------------------------------------------
# Régénération de tous les DNS 
# -----------------------------------------------------------------------------------------------------------------
	desc "Régénération de tous les DNS, direct et inverse"
	task :all_dns => :environment do

		Rake::Task["regenerate:supelec_dns"].invoke
		Rake::Task["regenerate:supelec_reverse_dns"].invoke
		Rake::Task["regenerate:other_dns"].invoke
		Rake::Task["regenerate:other_reverse_dns"].invoke
		Rake::Task["regenerate:external_dns"].invoke
		Rake::Task["regenerate:external_reverse_dns"].invoke

	end	

# -----------------------------------------------------------------------------------------------------------------
# Régénération des DNS supelec 
# -----------------------------------------------------------------------------------------------------------------
	desc "Régénération des DNS direct pour le VLAN::Supelec"
	task :supelec_dns => :environment do
		zf = Zonefile.new("$ORIGIN local.rez-rennes.supelec.fr.")
		zf.soa[:email] = 'rezo.rez-rennes.supelec.'
		zf.soa[:ttl] = 3600
		zf.soa[:primary] = 'ns.local.rez-rennes.supelec.fr.'
		zf.soa[:refresh] = '1d'
		zf.soa[:retry] = '2h'
		zf.soa[:expire] = '4w'
		zf.soa[:minimumTTL] = '1h'

		Computer.supelec.each do |computer|

			zf.a << { class: 'IN', name: computer.name, host: computer.ip_address} 

		end

		zf.new_serial

		puts zf.output
	end	


# -----------------------------------------------------------------------------------------------------------------
# Régénération des DNS inverse supelec 
# -----------------------------------------------------------------------------------------------------------------
	desc "Régénération des DNS inverse pour le VLAN::Supelec"
	task :supelec_reverse_dns => :environment do
		supelec_reverse_zonefile = Zonefile.new('./supelec_reverse_zonefile.db')

		Computer.supelec.each do |computer|

			supelec_reverse_zonefile.ptr << { class: 'IN', name: computer.reverse_ip, host: compute.name} 

		end

		supelec_reverse_zonefile.output
	end


# -----------------------------------------------------------------------------------------------------------------
# Régénération des DNS autre 
# -----------------------------------------------------------------------------------------------------------------
	desc "Régénération des DNS direct pour le VLAN::Autre"
	task :other_dns => :environment do
		others_zonefile = Zonefile.new('./others_zonefile.db')

		Computer.others.each do |computer|

			others_zonefile.ptr << { class: 'IN', name: computer.name, host: computer.ip_address} 

		end

		others_zonefile.output
	end


# -----------------------------------------------------------------------------------------------------------------
# Régénération des DNS inverse autre 
# -----------------------------------------------------------------------------------------------------------------
	desc "Régénération des DNS inverse pour le VLAN::Autre"
	task :other_reverse_dns => :environment do
		others_reverse_zonefile = Zonefile.new('./others_reverse_zonefile.db')

		Computer.others.each do |computer|

			others_reverse_zonefile.ptr << { class: 'IN', name: computer.reverse_ip, host: computer.name} 

		end

		others_reverse_zonefile.output
	end


# -----------------------------------------------------------------------------------------------------------------
# Régénération des DNS externe
# -----------------------------------------------------------------------------------------------------------------
	desc "Régénération des DNS externe inverse"
	task :external_dns => :environment do

	end


# -----------------------------------------------------------------------------------------------------------------
# Régénération des DNS inverse externe
# -----------------------------------------------------------------------------------------------------------------
	desc "Régénération des DNS externe inverse"
	task :external_reverse_dns => :environment do

	end

end