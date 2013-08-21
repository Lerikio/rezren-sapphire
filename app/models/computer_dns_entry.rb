# -*- encoding : utf-8 -*-
class ComputerDnsEntry < ActiveRecord::Base
	require 'ipaddr'

scope :not_archived, -> { where(archived: false)}


# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	

	attr_accessible :computer_id, :name

	belongs_to :computer, inverse_of: :computer_dns_entry
	has_many :alias_dns_entries, dependent: :destroy, inverse_of: :computer_dns_entry

# Avant validation
	
	before_validation do
		self.name = self.name.downcase if self.name.present?
	end

# Validations

	validates :name, presence: true,
		format: { with: /^([a-z0-9_\-\.]+)$/ }
	validates :computer, presence: true

##############################################################################################
#
#                Méthodes permettant de gérer les adresses IP pour les scripts 
#
##############################################################################################

	def ip_address
		self.computer.ip_address
	end

	def reverse_ip
		ip_addr = IPAddr.new self.ip_address
		ip_addr.reverse
	end

	# Génère un nom de domaine à partir du nom de famille de l'adhérent
	def self.generate_name(adherent_name)
		current_number = 2

		# Normalisation de la chaîne de caractère
		adherent_name = adherent_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s
		current_name = adherent_name

		# Tant qu'une entrée DNS existe déjà avec ce nom, on augmente le nombre qui lui est rajouté
		while ComputerDnsEntry.find_by_name(current_name)
			current_name = adherent_name + current_number.to_s
			current_number += 1
		end
		return current_name
	end
end
