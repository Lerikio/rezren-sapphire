# -*- encoding : utf-8 -*-
class Mailing < ActiveRecord::Base

	@domain_name = "rez-rennes.supelec.fr"

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	

	attr_accessible :adherent_id, :emails, :name, :system

	belongs_to :adherent, inverse_of: :mailing

	# Permet de stocker un tableau dans la base de donnée
		serialize :emails
		before_validation_on_create :emails = []


# Actions avant validation/sauvegarde
	# Création du nom complet de la mailing
	before_validation name = name.downcase + "@" + @domain_name

	# Mise en minuscule de toutes les emails
	before_save do
		self.emails.each do |email|
			email = email.downcase
		end
	end


# Validations

	validates :name, presence: true, uniqueness: true,
		format: { with: /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/ }
	validates :emails, presence: true
	validates :emails_validity

	# Une mailing peut être gérée par le système
	validates :adherent, presence:true, unless: :system?

private

	# Validation du format de chaque e-mail
	def emails_validity
		self.emails.each do |email|
			return false unless email.match /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/
		end
	end
	
end
