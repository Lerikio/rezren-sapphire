# -*- encoding : utf-8 -*-
class GenericDnsEntry < ActiveRecord::Base

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	

	attr_accessible :external, :name, :return, :type

# Avant validation
	
	before_validation name.downcase

# Validations

	validates :name, presence: true,
		format: { with: /^([a-z0-9_\-\.]+)$/ }
	validates :return, presence: true
	validates :type, presence: true


end
