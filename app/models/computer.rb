# -*- encoding : utf-8 -*-
class Computer < ActiveRecord::Base
	require 'resolv' #validation des adresses IP

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Filtres
	scope :not_archived, -> { where(archived: false)}
	scope :supelec, -> { where(adherent.room.port.vlan_connection.vlan = VLAN::Supelec) }
	scope :others,  -> { where(adherent.room.port.vlan_connection.vlan = VLAN::Autre) }

# Attributs et associations	
<<<<<<< HEAD
	attr_accessible :adherent_id, :mac_address, :ip_address, :computer_dns_entry_attributes
=======
	attr_accessible :adherent_id, :mac_address, :ip_address, :name
>>>>>>> 6d299dfb9b0a4c3197311b60d44d613cd23cfd8f

	belongs_to :adherent, inverse_of: :computers
	has_many :alias_dns_entries, dependent: :destroy, inverse_of: :computer

# Actions avant validation
	before_validation :generate_ip
	before_validation do
		self.name = self.name.downcase if self.name.present?
	end

# Validations
    validates :mac_address, presence: true, uniqueness: true,
        format: { with: /^([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}$/i }
    validates :adherent, presence: true
    validates :ip_address, presence: true, uniqueness: true, format: {with: Resolv::IPv4::Regex}
<<<<<<< HEAD
    validates :computer_dns_entry, presence: true

# Création de l'entrée DNS
	accepts_nested_attributes_for :computer_dns_entry


=======
   	validates :name, presence: true,
		format: { with: /^([a-z0-9_\-\.]+)$/ }
>>>>>>> 6d299dfb9b0a4c3197311b60d44d613cd23cfd8f

####################################################################################################
#
#                     Méthodes permettant de gérer les adresses IP facilement
# 
#       ===> les IPs sont gérées sous forme de tableau, puis rendue sous forme de string 	  
#
####################################################################################################

# --------------------------------------------------------------------------------------------------
#	Génère une adresse IP, la première disponible dans la DB
#	----> Algo de récupération du premier slot libre merdique !!!!!
# --------------------------------------------------------------------------------------------------

	def generate_ip
		if self.adherent.supelec
			vlan = VLAN::Supelec
		else
			vlan = VLAN::Exterieur
		end
		current_ip = [10, vlan, 1, 1]

		if Computer.all == []
			self.ip_address = self.to_ip(current_ip)
		else 
			Computer.all.each do |other_computer|
				unless other_computer.ip_address == to_ip(current_ip)
					self.ip_address = self.to_ip(current_ip)
					break
				end
				current_ip = increment_ip(current_ip)
			end
		end
	end


# --------------------------------------------------------------------------------------------------
#	Incrémente une adresse IP, sous forme de tableau
# --------------------------------------------------------------------------------------------------

	def increment_ip(current_ip)
		unless current_ip[3] == 253
			current_ip[3] += 1
		else
			if current_ip[2] < 255
				current_ip[2] += 1
				current_ip[3] = 1
			else
				raise "The argument #{self.to_ip(current_ip)} is already at max..."
			end
		end
	end


# --------------------------------------------------------------------------------------------------
#	Rend une chaîne de caractères à partir d'un tableau IP
# --------------------------------------------------------------------------------------------------

	def to_ip(array_ip)
		is_ipable = array_ip[0].is_a?(Integer) && array_ip[1].is_a?(Integer) && array_ip[2].is_a?(Integer) && array_ip[3].is_a?(Integer) && array_ip[0]<=255 && array_ip[0]<=255 && array_ip[0]<=255 && array_ip[0]<=253
		
		unless is_ipable 
			raise "The argument of to_ip method should be an array of the form [int, int, int, int]" 
		end

		array_ip[0].to_s + "." + array_ip[1].to_s + "." + array_ip[2].to_s + "." + array_ip[3].to_s
	end

# --------------------------------------------------------------------------------------------------
#	Renvoie l'adresse IP inverse pour les scripts DNS
# --------------------------------------------------------------------------------------------------

	def reverse_ip
		ip_addr = IPAddr.new self.ip_address
		ip_addr.reverse
	end

# --------------------------------------------------------------------------------------------------
#	Génère un nom de domaine à partir du nom de l'adhérent lors de la création
# --------------------------------------------------------------------------------------------------

	def self.generate_name(adherent_name)
		current_number = 2

		# Normalisation de la chaîne de caractère
		adherent_name = adherent_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s
		current_name = adherent_name

		# Tant qu'une entrée DNS existe déjà avec ce nom, on augmente le nombre qui lui est rajouté
		while Computer.find_by_name(current_name)
			current_name = adherent_name + current_number.to_s
			current_number += 1
		end
		return current_name
	end
end
