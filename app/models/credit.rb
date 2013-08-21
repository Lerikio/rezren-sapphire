# -*- encoding : utf-8 -*-
class Credit < ActiveRecord::Base

scope :not_archived, -> { where(archived: false)}

attr_accessible :payments_attributes

# Attributs et associations	

	has_many :payments, inverse_of: :credit
	belongs_to :adherent, dependent: :destroy, inverse_of: :credit

# Validations

	validates :adherent, presence: true
	validates :next_debit, presence: true
	validates :value, presence: true

# Nested attributes
	accepts_nested_attributes_for :payments


end