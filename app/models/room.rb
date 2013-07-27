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
	validates :number, :uniqueness => {:scope => :building}
	validates :port, presence: true

def full_address
	self.building + self.number
end

end
