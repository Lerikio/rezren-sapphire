# -*- encoding : utf-8 -*-
class Adherent < ActiveRecord::Base

scope :not_archived, -> { where(archived: false)}

# Surveillance par la gem public_activity
	include PublicActivity::Common

# --------------------------------------------------------------------------------------------------
#	Attributs
# --------------------------------------------------------------------------------------------------

	attr_accessible :full_name, :password, :password_confirmation, :email, :username, :promotion, :room,
		:rezoman, :resident, :supelec,
		:computers_attributes, :credit_attributes
			# La première ligne correspond à l'identité à proprement dit de l'adhérent
			# La seconde ligne à des booléens qui permettent d'identifier les droits de l'adhérent
				# Rezoman : permet de se connecter dans toutes les chambres, et de ne pas payer sa connexion.
				# Resident : Un resident n'a pas d'ordinateurs, de solde ou de connexion.
				# Supelec : un supelec a le droit à un compte discourse, et est sur le VLAN::Supelec
			# La dernière ligne permet la création d'un compte adhérent complet en un seul formulaire.

	# :password n'est pas stocké dans la base de donnée, il permet simplement de réaliser les formulaires.
	attr_accessor :password

# --------------------------------------------------------------------------------------------------
#	Associations
# --------------------------------------------------------------------------------------------------

	has_many :mailings, inverse_of: :adherent 	# Un adhérent peut être propriétaire de mailings
	has_many :payments, through: :credit

	has_one :room, inverse_of: :adherent	# Un adhérent resident a une chambre
	#has_one :admin, inverse_of: :adherent  # Un adhérent peut être lié à un administrateur

	# Association forte
	has_many :computers, dependent: :destroy, inverse_of: :adherent
	has_one :credit, dependent: :destroy, inverse_of: :adherent

# --------------------------------------------------------------------------------------------------
#	Actions avant sauvegarde
# --------------------------------------------------------------------------------------------------

	before_save :encrypt_password
	before_save { |adherent| adherent.email = adherent.email.downcase}

# --------------------------------------------------------------------------------------------------
#	Validations
# --------------------------------------------------------------------------------------------------

	validates :full_name, presence: true
	validates :email, presence: true, uniqueness: true,
		format: { with: /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/ }
	
	# S'il s'agit d'un supélec :
	validates :password, confirmation: true, length: {minimum: 6}, presence: true, if: :supelec?
	validates :promotion, presence: true, if: :supelec?
	validates :username, presence: true, if: :supelec?
	validates :username, uniqueness: true, length: {minimum: 3},
		:format => { :with => /^([a-zA-Z0-9_\-\.]+)$/ }, if: :supelec?
	
	# S'il s'agit d'un résident :
	validates :credit, presence: true, if: :resident?
	validates :room, presence: true, if: :resident?

# --------------------------------------------------------------------------------------------------
#	Nested forms
# --------------------------------------------------------------------------------------------------

	accepts_nested_attributes_for :computers, reject_if: :not_resident?, :allow_destroy => true
	accepts_nested_attributes_for :credit, reject_if: :not_resident?

# --------------------------------------------------------------------------------------------------
#	Machine d'état
# --------------------------------------------------------------------------------------------------

state_machine :state, initial: :created do
	
	event :validate do
		transition :created => :connected
	end
	
	event :disconnect do
		transition [:connected, :freely_connected] => :disconnected
	end
	
	event :to_rezoman do
		transition [:connected, :created, :disconnected] => :freely_connected
	end

  end

# --------------------------------------------------------------------------------------------------
#	Méthodes
# --------------------------------------------------------------------------------------------------

	def room_id
		room.id if room
	end
	
private

	# Devrait être déplacé pour factorisation du code avec les admins
		def encrypt_password
			if password.present?
				self.password_salt = BCrypt::Engine.generate_salt
				self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
			end
		end

		def not_resident?
			not resident?
		end

end
