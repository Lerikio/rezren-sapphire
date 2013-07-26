# -*- encoding : utf-8 -*-
class Switch < ActiveRecord::Base

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	

	attr_accessible :community, :ip_admin

	has_many :ports, dependent: :destroy

# Validations

	validates :community, presence: true
	validates :ip_admin, presence: true, uniqueness: true

end
