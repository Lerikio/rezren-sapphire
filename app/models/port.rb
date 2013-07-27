# -*- encoding : utf-8 -*-
class Port < ActiveRecord::Base

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	

	attr_accessible :number, :switch_id

	has_many :vlans, through: :connexion
	has_one :room
	belongs_to :switch, dependent: :destroy

# Validations

	validates :number, presence: true
	validates :switch, presence: true

	#charge l'état du port (enabled/disabled) et les vlans correspondants par SNMP
	def refresh_from_snmp()
		#switch.access or return
		#TODO
		snmp_interface = self.switch.snmp_interface
		vlans_nums = snmp_interface.vlans_ids

		vlans_nums.each do |vlan_number|
			if interface.is_on_vlan?(self.number,vlan_number) && !self.vlans.find_by number: vlan_number
				self.vlans << Vlan.find_by number: vlan_number
			end
		end

		self.connexions.each do |connexion|
			vlan_number = connexion.vlan.number
			unless interface.is_on_vlan?(self.number,vlan_number)
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

	def update_snmp()
		#switch.access or return
		#TODO
		snmp_interface = self.switch.snmp_interface
		vlans_nums = snmp_interface.vlans_ids

		vlans_nums.each do |vlan_number|
			if interface.is_on_vlan?(self.number,vlan_number) && !self.vlans.find_by number: vlan_number
				self.vlans << Vlan.find_by number: vlan_number
			end
		end

		self.connexions.each do |connexion|
			vlan_number = connexion.vlan.number
			unless interface.is_on_vlan?(self.number,vlan_number)
				connexion.destroy
				return
			end
			if vlans_nums.include? vlan_num 
				connexion.tagged=snmp_interface.is_on_tagged_vlan?(self.number,vlan_number)
				connexion.save
			end
		end
		self.enabled=snmp_interface.enabled?(self.number)
	end
	
end
