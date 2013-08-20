# -*- encoding : utf-8 -*-
class Mailing < ActiveRecord::Base

	scope :not_archived, -> { where(archived: false)}


	DomainName = "rez-rennes.supelec.fr"

# Surveillance par la gem public_activity
	include PublicActivity::Common

# --------------------------------------------------------------------------------------------------
#	Attributs & associations
# --------------------------------------------------------------------------------------------------

	attr_accessible :adherent_id, :emails, :name, :system

	belongs_to :adherent, inverse_of: :mailings

	# Permet de stocker un tableau dans la base de donnée
	serialize :emails, Array

# --------------------------------------------------------------------------------------------------
#	Actions avant sauvegarde/validation
# --------------------------------------------------------------------------------------------------

	# Création du nom complet de la mailing
	before_validation do
		self.name = self.name.downcase
	end

	# Mise en minuscule de toutes les emails
	before_save do
		emails.reject! { |e| e.empty? }
		self.emails.each do |email|
			email = email.downcase
		end
	end

# --------------------------------------------------------------------------------------------------
#	Validations
# --------------------------------------------------------------------------------------------------

	validates :name, presence: true, uniqueness: true,
		format: { with: /^([a-zA-Z0-9_\-\.]+)$/ }
	validates :emails, presence: true
	validate :emails_validity

	# Une mailing peut être gérée par le système
	validates :adherent, presence:true, unless: :system?


# --------------------------------------------------------------------------------------------------
#	Méthodes
# --------------------------------------------------------------------------------------------------

	def address
		self.name + "@" + DomainName
	end

private

	# Validation du format de chaque e-mail
	def emails_validity
		self.emails.each do |email|
			return false unless email.match /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/
		end
	end

end
