# -*- encoding : utf-8 -*-
class Port < ActiveRecord::Base

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	

	attr_accessible :number, :switch_id

	has_many :vlan_connections, inverse_of: :port, dependent: :destroy
	has_one :room, inverse_of: :port
	belongs_to :switch, inverse_of: :ports

# Validations

	validates :number, presence: true
	validates :switch, presence: true

	#charge l'état du port (enabled/disabled) et les vlans correspondants par SNMP
	#Ne fonctionne pas
	# def refresh_from_snmp

	# 	snmp_interface = self.switch.snmp_interface
	# 	vlans_nums = snmp_interface.vlans_ids

	# 	vlans_nums.each do |vlan_number|
	# 		if snmp_interface.is_on_vlan?(self.number,vlan_number) && self.vlan_connections.where(vlan: vlan_number).empty?
	# 			self.vlan_connections << new VlanConnection(vlan: Vlan.find_by_number(vlan_number))
	# 		end
	# 	end

	# 	self.vlan_connections.each do |vlan_connection|
	# 		vlan_number = vlan_connection.vlan
	# 		unless snmp_interface.is_on_vlan?(self.number,vlan_number)
	# 			vlan_connection.destroy
	# 			return
	# 		end
	# 		if vlans_nums.include? vlan_num 
	# 			connexion.tagged=snmp_interface.is_on_tagged_vlan?(self.number,vlan_number)
	# 			connexion.save
	# 		end
	# 	end
	# 	self.enabled=snmp_interface.enabled?(self.number)
	# 	save
	# end

	def update_vlans_by_snmp
		snmp_interface = self.switch.snmp_interface
		vlans_nums = snmp_interface.vlans_ids

		vlans_nums.each do |vlan_number|
			if snmp_interface.is_on_vlan?(self.number,vlan_number) && self.vlan_connections.where(vlan: vlan_number).empty?
				snmp_interface.del_vlan(self.number,vlan_number)
			end
		end

		self.vlan_connections.each do |vlan_connection|
			vlan_number = vlan_connection.vlan.number
			if vlan_connection.tagged
				snmp_interface.add_vlan_tagged(self.number,vlan_number)
			else
				snmp_interface.add_vlan_untagged(self.number,vlan_number)
			end
		end
	end

	def update_mac_addresses_by_snmp
		snmp_interface = self.switch.snmp_interface
		macs_to_add = []
		supelec = self.room.adherent.supelec?
		vlan = if supelec then VLAN::Supelec else VLAN::Exterieur end
		self.room.adherent.computers.each do |computer|
			macs_to_add << {:mac => computer.mac_address, :vlan => vlan}
		end

		snmp_interface.flush_macs(self.number)
		
		macs_to_add.each do |mac_vlan|
			add_mac(self.number, mac_vlan[:vlan], mac_vlan[:mac])
		end
	end
	
end
