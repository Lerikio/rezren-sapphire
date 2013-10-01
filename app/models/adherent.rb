# -*- encoding : utf-8 -*-
class Adherent < ActiveRecord::Base

require 'discourse_api/discourse_api'


scope :not_archived, -> { where(archived: false)}

# Surveillance par la gem public_activity
	include PublicActivity::Common

# --------------------------------------------------------------------------------------------------
#	Attributs
# --------------------------------------------------------------------------------------------------

	attr_accessible :first_name, :last_name, :password, :password_confirmation, :email, :username, :promotion, :room, :supelec_email, :use_supelec_email,
		:rezoman, :resident, :supelec,
		:computers_attributes, :credit_attributes
			# La première ligne correspond à l'identité à proprement dit de l'adhérent
			# La seconde ligne à des booléens qui permettent d'identifier les droits de l'adhérent
				# Rezoman : permet de se connecter dans toutes les chambres, et de ne pas payer sa connexion.
				# Resident : Un resident n'a pas d'ordinateurs, de solde ou de connexion.
				# Supelec : un supelec a le droit à un compte discourse, et est sur le VLAN::Supelec
			# La dernière ligne permet la création d'un compte adhérent complet en un seul formulaire.

	# ne sont pas stockés dans la base de donnée, ils permet simplement de réaliser les formulaires.
	attr_accessor :password

# --------------------------------------------------------------------------------------------------
#	Associations
# --------------------------------------------------------------------------------------------------

	has_many :mailings, inverse_of: :adherent 	# Un adhérent peut être propriétaire de mailings
	has_many :payments, through: :credit

	has_one :room, inverse_of: :adherent	# Un adhérent resident a une chambre

	# Association forte
	has_many :computers, dependent: :destroy, inverse_of: :adherent
	has_one :credit, dependent: :destroy, inverse_of: :adherent

# --------------------------------------------------------------------------------------------------
#	Actions avant sauvegarde et validation
# --------------------------------------------------------------------------------------------------

	before_validation :ensure_consistency

	before_save :encrypt_password
	before_save { |adherent| adherent.email = adherent.email.downcase}

# --------------------------------------------------------------------------------------------------
#	Validations
# --------------------------------------------------------------------------------------------------

	validates :first_name, :last_name, presence: true
	validates :email, presence: true, uniqueness: true,
		format: { with: /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/ }
	
	# S'il s'agit d'un supélec :
	validates :password, confirmation: true, presence: true, length: {minimum: 6}, if: :should_validate_password?
	validates :promotion, presence: true, if: :supelec?
	validates :username, uniqueness: true, length: {minimum: 3}, presence: true,
		:format => { :with => /^([a-zA-Z0-9_\-\.]+)$/ }, if: :supelec?
	validates :supelec_email, uniqueness: true, presence: true, if: :supelec?
	validates :supelec_email, format: { with: /^([a-zA-Z0-9_\-\.]+)$/ }, if: :supelec?

	# S'il s'agit d'un résident :
	validates :credit, presence: true, if: :resident?
	validates :room, presence: true, if: :resident?

# --------------------------------------------------------------------------------------------------
#	Nested forms
# --------------------------------------------------------------------------------------------------

	accepts_nested_attributes_for :computers, reject_if: :not_resident?, :allow_destroy => true
	accepts_nested_attributes_for :credit, reject_if: :not_resident?

# --------------------------------------------------------------------------------------------------
#	Création du compte discourse 
# --------------------------------------------------------------------------------------------------

	#after_create :create_discourse_user

# --------------------------------------------------------------------------------------------------
#	Méthodes
# --------------------------------------------------------------------------------------------------

# Création d'un utilisateur discourse

	def create_discourse_user 
		if supelec?
			client = DiscourseApi::Client.new("193.54.193.2")
			client.api_key = "59f0959060761f1414c6cf7c23b843841059b4bf7d34ad808d979e4598faab27"
			client.api_username = "Lerik"
			client.create_user(name: full_name, email: email_to_use, password: password, username: username)
			self.discourse_created = true
			self.save
		end
	end


# Devrait être déplacé pour factorisation du code avec les admins
		def encrypt_password
			if password.present?
				self.password_salt = BCrypt::Engine.generate_salt
				self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
			end
		end

	# Modifie les données pour s'assurer ques les informations de l'adhérent soient cohérentes
		def ensure_consistency
			if not_resident?
				room = nil
			end
			if not_supelec?
				promotion = nil
				password = nil
				username = nil
				supelec_email = nil				
			end
		end

# --------------------------------------------------------------------------------------------------
#	Helpers
# --------------------------------------------------------------------------------------------------

	def room_id
		room.id if room
	end
	
	def full_name
		self.first_name + " " + self.last_name
	end

	def full_supelec_address
		if supelec_email
			supelec_email + "@supelec.fr"
		end
	end

	def email_to_use
		if use_supelec_email
			supelec_email
		else
			email
		end
	end

	def actif?
		credit.actif?
	end

	def should_be_disconnected?
		!credit or credit.should_be_disconnected?
	end

	def should_validate_password?
		(self.password && !self.password.blank?) || ( supelec? && self.new_record?)
	end

private
	
		def not_resident?
			not resident?
		end

		def not_supelec?
			not supelec?
		end
end
