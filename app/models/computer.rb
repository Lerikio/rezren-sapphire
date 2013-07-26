# -*- encoding : utf-8 -*-
class Computer < ActiveRecord::Base
	require 'resolv' #validation des adresses IP

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	
	attr_accessible :adherent_id, :mac_address, :ip_address

	belongs_to :adherent, dependent: :destroy
	has_many :dns_entries

# Actions avant sauvegarde
	before_save self.ip_address = generate_ip_address

# Validations
    validates :mac_address, presence: true, uniqueness: true,
        format: { with: /^([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}$/i }
    validates :adherent, presence: true, unless: :server?
    validates :ip_address, presence: true, uniqueness: true, format: {with: Resolv::IPV4::Regex}


private


	## Méthodes permettant de gérer les adresses IP facilement
		# Permet de générer une adresse IP
		# ----> Algo de récupération du premier slot libre merdique !!!!!
		def generate_ip_address
			vlan = self.adherent.room.port.vlan.number
			current_ip = [10, vlan, 0, 1]

			Computer.all.each do |other_computer|
				unless other_computer.ip_address == to_ip(current_ip)
					return selfto_ip(current_ip)
				end
				current_ip = increment_ip(current_ip)
			end
		end

		def increment_ip(current_ip)
			unless current_ip[3] == 253
				current_ip[3] += 1
			else
				if current_ip[2] < 255
					current_ip[2] += 1
					current_ip[3] = 1
				else
					raise "The argument #{to_ip(current_ip)} is already at max..."
				end
			end
		end

		def to_ip(array_ip)
			is_ipable = array_ip[0].is_a? Integer && array_ip[1].is_a? Integer && array_ip[2].is_a? Integer && array_ip[3].is_a? Integer
						&& array_ip[0]<=255 && array_ip[0]<=255 && array_ip[0]<=255 && array_ip[0]<=253
			
			unless is_ipable 
				raise "The argument of to_ip method should be an array of the form [ int, int, int, int]" 
			end

			string_ip = array_ip[0].to_s + "." + array_ip[1].to_s + "." + array_ip[2].to_s + "." + array_ip[3].to_s
		end


end
