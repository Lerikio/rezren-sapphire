# encoding : UTF-8
#
# ----------------------------------------------------------------------------------------------------------------
#
# Mise à jour des switches par SNMP
#
# Script réalisé en août 2013 par Tom GONEL (Promo 2015)
#
# ----------------------------------------------------------------------------------------------------------------


namespace :snmp do

	desc "Met à jour les VLANs sur les switches"
	task :vlans => :environment do |t, args|
		changes = {}
		Switch.not_archived.each do |switch|
			switch_changes = []
			switch.ports.each do |port|
				switch_changes << port.update_vlans_by_snmp
			end
			switch_changes.delete_if { |v| v.nil? }
			changes[switch.description] = switch_changes
		end
		#TODO formater les logs
		puts changes
		Log.new(:content => changes, :source => "Script de mise à jour des VLANs", :status => "info").save
	end

	desc "Met à jour les adresses MACs autorisées sur les switches"
	task :macs => :environment do |t, args|
		changes = {}
		Switch.not_archived.each do |switch|
			switch_changes = []
			switch.ports.each do |port|
				switch_changes << port.update_mac_addresses_by_snmp
			end
			switch_changes.delete_if { |v| v.nil? }
			changes[switch.description] = switch_changes
		end
		#TODO formater les logs
		puts changes
		Log.new(:content => changes, :source => "Script de mise à jour des MACs", :status => "info").save
	end

	task :all => :environment
		Rake::Task["snmp:vlans"].invoke
		Rake::Task["snmp:macs"].invoke
	end
end