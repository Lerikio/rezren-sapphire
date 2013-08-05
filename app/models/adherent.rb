# -*- encoding : utf-8 -*-
class Adherent < ActiveRecord::Base

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations

	attr_accessible :full_name, :password, :password_confirmation, :email, :username,
		:rezoman, :externe, :supelec,
		:computer_attributes, :credit_attributes, :payment_attributes
			# La première ligne correspond à l'identité à proprement dit de l'adhérent
			# La seconde ligne à des booléens qui permettent d'identifier les droits de l'adhérent
				# Rezoman : permet de se connecter dans toutes les chambres, et de ne pas payer sa connexion.
				# Externe : Un externe n'a pas d'ordinateurs, de solde ou de connexion.
				# Supelec : un supelec a le droit à un compte discourse, et est sur le VLAN::Supelec
			# La dernière ligne permet la création d'un compte adhérent complet en un seul formulaire.

	# :password n'est pas stocké dans la base de donnée, il permet simplement de réaliser les formulaires.
	attr_accessor :password

	has_many :mailings, inverse_of: :adherent 	# Un adhérent peut être propriétaire de mailings
	has_many :payments, through: :credit

	has_one :room, inverse_of: :adherent	# Un adhérent non-externe a une chambre
	#has_one :admin, inverse_of: :adherent  # Un adhérent peut être lié à un administrateur

	# Association forte
	has_many :computers, dependent: :destroy, inverse_of: :adherent
	has_one :credit, dependent: :destroy, inverse_of: :adherent

# Actions avant sauvegarde
	before_save :encrypt_password
	before_save { |adherent| adherent.email = adherent.email.downcase}

# Validations. Certaines expressions régulières sont un peu longue...
	validates :password, confirmation: true, presence: true, length: {minimum: 6}
	validates :full_name, presence: true
	validates :email, presence: true, uniqueness: true,
		format: { with: /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/ }
	validates :username, presence: true, unless: :supelec?
	validates :username, uniqueness: true, length: {minimum: 3},
		:format => { :with => /^([a-zA-Z0-9_\-\.]+)$/ }

	validates :credit, presence: true, unless: :externe?
	validates :room, presence: true, unless: :externe?


# Permet les nested forms pour le rezotage.
	accepts_nested_attributes_for :computers, reject_if: lambda { |a| a[:content].blank}, :allow_destroy => true
	accepts_nested_attributes_for :credit

# Machine d'état

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

# Méthodes de classe

private

	# Devrait être déplacé pour factorisation du code avec les admins
		def encrypt_password
			if password.present?
				self.password_salt = BCrypt::Engine.generate_salt
				self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
			end
		end

end
