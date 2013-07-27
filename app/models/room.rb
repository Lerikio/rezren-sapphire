# -*- encoding : utf-8 -*-
class Room < ActiveRecord::Base

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	
	attr_accessible :adherent_id, :building, :number, :port_id

	belongs_to :adherent
	belongs_to :port

#Validations. Une chambre peut-être vide et sans ip-phone !
	validates :number, presence: true
	validates :building, presence: true
	validate :uniqueness_of_address
	validates :port, presence: true

def full_address
	self.building + self.number
end

private

	# Renvoie faux si une chambre a le même building et le même number
	def uniqueness_of_address
		Room.all.each do |other_room|
			return false if other_room.number == self.number && other_room.building == self.building
		end
		
		return true
	end

end
