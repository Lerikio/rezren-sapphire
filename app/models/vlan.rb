# -*- encoding : utf-8 -*-
class Vlan < ActiveRecord::Base

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	

	attr_accessible :name, :number

	has_many :ports, through: :connexion

# Validations

	validates :name, presence: true, uniqueness: true
	validates :number, presence: true, uniqueness: true

end
