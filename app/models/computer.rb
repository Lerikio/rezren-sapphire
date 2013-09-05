# -*- encoding : utf-8 -*-
class Computer < ActiveRecord::Base
	require 'resolv' #validation des adresses IP

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Filtres
	scope :not_archived, -> { where(archived: false)}

# Attributs et associations	
	attr_accessible :adherent_id, :mac_address, :ip_address, :name

	belongs_to :adherent, inverse_of: :computers
	has_many :alias_dns_entries, dependent: :destroy, inverse_of: :computer

# Actions avant validation
	before_validation :generate_ip
	before_validation :on => :create do 
		self.name = Computer.generate_name(adherent.last_name)
	end
	before_validation do
		self.mac_address = self.mac_address.downcase
	end
	

# Validations
    validates :mac_address, presence: true,
        format: { with: /^([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}$/i }
    validates :adherent, presence: true
    validates :ip_address, presence: true, format: {with: Resolv::IPv4::Regex}
   	validates :name, presence: true,
		format: { with: /^([a-z0-9_\-\.]+)$/ }
	validate :uniqueness_mac_ip

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
		return if self.ip_address
		if self.adherent.supelec
			vlan = VLAN::Supelec
		else
			vlan = VLAN::Exterieur
		end
		current_ip = [10, vlan, 1, 1]

		computers = Computer.where(:archived => false)

		if computers.empty?
			self.ip_address = self.to_ip(current_ip)
		else 
			while true do
				if computers.where(:ip_address => self.to_ip(current_ip)).empty?
					break
				end
				current_ip = increment_ip(current_ip)
			end
			self.ip_address = self.to_ip(current_ip)
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
		current_ip
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
		adherent_name = adherent_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').gsub(/\s+/, "").downcase.to_s
		current_name = adherent_name

		# Tant qu'une entrée DNS existe déjà avec ce nom, on augmente le nombre qui lui est rajouté
		while Computer.find_by_name(current_name)
			current_name = adherent_name + current_number.to_s
			current_number += 1
		end
		return current_name
	end

# --------------------------------------------------------------------------------------------------
#	Filtres non faisables via des scopes
# --------------------------------------------------------------------------------------------------

	def self.supelec
		computers = []
		Computer.all.each do |computer|
			computers << computer if computer.adherent.supelec
		end
		computers
	end

	def self.others
		computers = []
		Computer.all.each do |computer|
			computers << computer unless computer.adherent.supelec
		end
		computers
	end

	def uniqueness_mac_ip
		errors.add(:ip_address, 'doit être unique') unless Computer.not_archived.where(:ip_address => self.ip_address).where('id <> ?', self.id).empty?
		errors.add(:mac_address, 'doit être unique') unless Computer.not_archived.where(:mac_address => self.mac_address).where('id <> ?', self.id).empty?
		true
	end
end
