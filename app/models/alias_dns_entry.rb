# -*- encoding : utf-8 -*-
class AliasDnsEntry < ActiveRecord::Base

# Surveillance par la gem public_activity
	include PublicActivity::Common
	
# Attributs et associations	

	attr_accessible :computer_dns_entry_id, :name

	belongs_to :computer_dns_entry, dependent: :destroy, inverse_of: :alias_dns_entries
	has_one :computer, through: :computer_dns_entry

# Avant validation
	
	before_validation name.downcase

# Validations

	validates :name, presence: true,
		format: { with: /^([a-z0-9_\-\.]+)$/ }
	validates :computer_dns_entry, presence: true

	def ip_address
		self.computer.ip_address
	end

end
