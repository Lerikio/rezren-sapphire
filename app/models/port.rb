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
	def refresh_from_snmp
		#switch.access or return
		#TODO
		snmp_interface = self.switch.snmp_interface
		vlans_nums = snmp_interface.vlans_ids

		vlans_nums.each do |vlan_number|
			if snmp_interface.is_on_vlan?(self.number,vlan_number) && !self.vlans.find_by_number(vlan_number)
				self.vlans << Vlan.find_by_number(vlan_number)
			end
		end

		self.connexions.each do |connexion|
			vlan_number = connexion.vlan.number
			unless snmp_interface.is_on_vlan?(self.number,vlan_number)
				connexion.destroy
				return
			end
			if vlans_nums.include? vlan_num 
				connexion.tagged=snmp_interface.is_on_tagged_vlan?(self.number,vlan_number)
				connexion.save
			end
		end
		self.enabled=snmp_interface.enabled?(self.number)
		save
	end

	def update_snmp
		#switch.access or return
		#TODO
		snmp_interface = self.switch.snmp_interface
		vlans_nums = snmp_interface.vlans_ids

		vlans_nums.each do |vlan_number|
			if snmp_interface.is_on_vlan?(self.number,vlan_number) && !self.vlans.find_by_number(vlan_number)
				snmp_interface.del_vlan(self.number,vlan_number)
			end
		end

		self.connexions.each do |connexion|
			vlan_number = connexion.vlan.number
			if connexion.tagged
				snmp_interface.add_vlan_tagged(self.number,vlan_number)
			else
				snmp_interface.add_vlan_untagged(self.number,vlan_number)
			end
		end
		self.enabled=snmp_interface.enabled?(self.number)
	end
	
end
