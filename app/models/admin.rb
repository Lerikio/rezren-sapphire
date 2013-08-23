# -*- encoding : utf-8 -*-
class Admin < ActiveRecord::Base

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations
	attr_accessible :password, :password_confirmation, :username

	attr_accessor :password

	has_and_belongs_to_many :roles
	has_many :payments, inverse_of: :admin

# Actions avant sauvegarde
	before_save :encrypt_password

# Validations
	validates :password, confirmation: true, presence: true, length: {minimum: 6}
	validates :username, presence: true, uniqueness: true, length: {minimum: 3}

# Méthodes de classe
	def self.authenticate(username, password)
		username = username.downcase
		user = where('lower(username) = ?', username).first
		if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
			user
		else
			nil # Pas obligatoire, là pour la compréhension
		end
	end

	# Devrait être déplacé pour factorisation du code avec les adhérents
	def encrypt_password
		if password.present?
			self.password_salt = BCrypt::Engine.generate_salt
			self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
		end
	end
end
