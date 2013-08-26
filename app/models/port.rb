# -*- encoding : utf-8 -*-
class Port < ActiveRecord::Base

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	

	attr_accessible :number, :switch_id

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
		#On récupère l'interface SNMP et les numéros des VLANs gérés par ce switch
		snmp_interface = self.switch.snmp_interface
		vlans_nums = snmp_interface.vlans_ids

		#On met les chambres non rézotées sur le VLAN de prérézotage
		unless room.nil? or room.adherent.nil? or room.adherent.should_be_disconnected?
			if snmp_interface.is_on_vlan?(self.number,VLAN::Prerezotage)
				snmp_interface.add_vlan_untagged(self.number,VLAN::Prerezotage)
				return {:vlan => VLAN::Prerezotage, :tagged => false}
			end
			return true
		end

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
		return nil unless room && room.adherent
		snmp_interface = self.switch.snmp_interface
		old_macs = format_mac_addresses(snmp_interface.list_macs(self.number))
		new_macs = []
		supelec = self.room.adherent.supelec?
		vlan = if supelec then VLAN::Supelec else VLAN::Exterieur end
		self.room.adherent.computers.each do |computer|
			new_macs << {:mac => computer.mac_address, :vlan => vlan}
		end

		#Apparement on peut faire des différences de tableaux de hashs
		macs_to_add = new_macs - old_macs
		macs_to_delete = old_macs - new_macs

		macs_to_add.each do |mac|
			add_mac(self.number, mac[:vlan], mac[:mac])
		end

		macs_to_delete.each do |mac|
			del_mac(self.number, mac[:vlan], mac[:mac])
		end

		{:port => self.number, :added => macs_to_add, :deleted => macs_to_delete}
	end
	
	private

	#Le texte brut est de la forme "VLAN1 MAC1,VLAN1 MAC2"
	def format_mac_addresses(text)
		macs = []
		text.split(",").each do |part|
			tmp = part.split("\s")
			macs << {:mac => tmp[1], :vlan => tmp[0]}
		end
		macs
	end
end
