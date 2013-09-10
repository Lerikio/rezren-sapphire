# -*- encoding : utf-8 -*-
class Admin < ActiveRecord::Base

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations
	attr_accessible :password, :password_confirmation, :display_name, :username

	attr_accessor :password

	has_and_belongs_to_many :roles
	has_many :payments, inverse_of: :admin

# Actions avant sauvegarde/validation
	before_validation :normalize_username
	before_save :encrypt_password

# Validations
	validates :password, confirmation: true, presence: true, length: {minimum: 6}
	validates :display_name, presence: true
	validates :username, presence: true, uniqueness: true, length: {minimum: 3}

# Méthodes de classe
	def self.authenticate(username, password)
		username = username.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s
		user = find_by_username(username)
		return nil if user.archived
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

	private
	# On stocke sous forme normalisée l'username pour simplifier le login
	def normalize_username
		self.username = self.display_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s
	end
end
