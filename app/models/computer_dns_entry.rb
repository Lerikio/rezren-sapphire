# -*- encoding : utf-8 -*-
class ComputerDnsEntry < ActiveRecord::Base
	require 'ipaddr'
# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	

	attr_accessible :computer_id, :name

	belongs_to :computer, inverse_of: :computer_dns_entry
	has_many :alias_dns_entries, dependent: :destroy, inverse_of: :computer_dns_entry

# Avant validation
	
	before_validation :downcase_name

# Validations

	validates :name, presence: true,
		format: { with: /^([a-z0-9_\-\.]+)$/ }
	validates :computer, presence: true

##############################################################################################
#
#                Méthodes permettant de gérer les adresses IP pour les scripts 
#
##############################################################################################

	def ip_address
		self.computer.ip_address
	end

	def reverse_ip
		ip_addr = IPAddr.new self.computer.ip_address
		ip_addr.reverse
	end


	private

	def downcase_name
		self.name = self.name.downcase if self.name.present?
	end
end
