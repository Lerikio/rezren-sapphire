# -*- encoding : utf-8 -*-
class GenericDnsEntry < ActiveRecord::Base

scope :not_archived, -> { where(archived: false)}

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	

	attr_accessible :external, :name, :return, :dns_type

# Avant validation
	
	before_validation do
		self.name = self.name.downcase if self.name.present?
	end
# Validations

	validates :name, presence: true,
		format: { with: /^([a-z0-9_\-\.]+)$/ }
	validates :return, presence: true
	validates :dns_type, presence: true

end
