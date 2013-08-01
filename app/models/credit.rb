# -*- encoding : utf-8 -*-
class Credit < ActiveRecord::Base

# Attributs et associations	

	attr_accessible :next_debit, :value

	has_many :payments, inverse_of: :credit
	belongs_to :adherent, dependent: :destroy, inverse_of: :credit

# Validations

	validates :adherent, presence: true
	validates :next_debit, presence: true
	validates :value, presence: true

end
