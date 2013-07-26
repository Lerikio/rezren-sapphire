# -*- encoding : utf-8 -*-
class ComputerDnsEntry < ActiveRecord::Base

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	

	attr_accessible :computer_id, :name

	belongs_to :computer, dependent: :destroy
	has_many :alias_dns_entries, dependent: :destroy

# Avant validation
	
	before_validation self.name = self.name.downcase

# Validations

	validates :name, presence: true,
		format: { with: /^([a-z0-9_\-\.]+)$/ }
	validates :computer, presence: true

	def ip_address
		self.computer.ip_address
	end

end
