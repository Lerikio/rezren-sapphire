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

end
