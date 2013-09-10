# -*- encoding : utf-8 -*-
class Room < ActiveRecord::Base

scope :not_archived, -> { where(archived: false)}

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	
	attr_accessible :adherent_id, :building, :number, :port_id

	belongs_to :adherent, inverse_of: :room
	belongs_to :port, inverse_of: :room

#Validations. Une chambre peut-être vide et sans ip-phone !
	validates :number, presence: true, uniqueness: {scope: :building}
	validates :building, presence: true
	#validates :port, presence: true


	
	def full_address
		self.building + self.number
	end

	def address_and_adherent
		return self.full_address unless self.adherent
		self.full_address + ' (' + self.adherent.full_name + ')'
	end

end
