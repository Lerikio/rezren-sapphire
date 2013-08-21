# -*- encoding : utf-8 -*-
class AliasDnsEntry < ActiveRecord::Base

scope :not_archived, -> { where(archived: false)}

# Surveillance par la gem public_activity
	include PublicActivity::Common
	
# Attributs et associations	

	attr_accessible :computer_id, :name

	belongs_to :computer, inverse_of: :alias_dns_entries

# Avant validation
	
	before_validation do
		self.name = self.name.downcase if self.name.present?
	end

# Validations

	validates :name, presence: true,
		format: { with: /^([a-z0-9_\-\.]+)$/ }
	validates :computer, presence: true

	def ip_address
		self.computer.ip_address
	end
end
