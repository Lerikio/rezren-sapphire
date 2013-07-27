# -*- encoding : utf-8 -*-
class Payment < ActiveRecord::Base

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	

	attr_accessible :comment, :mean, :paid_value, :value, :bank_name

	belongs_to :credit
	belongs_to :admin
	has_one :adherent, through: :credit


# Validations

	validates :value, presence: true
	validates :paid_value, presence: true

	validates :comment, presence: true, unless: self.paid_value==self.value

	validate :mean_is_correct
	validates :bank_name, presence: true, if: self.mean == "cheque"

	validates :credit, presence: true
	validates :admin, presence: true

# Machine d'état

state_machine :state, initial: :received do

	after_transition all => :cashed, do: self.cashed_date = Time.now

	event :by_treasurer do
		transition :received => :received_by_treasurer
	end
	
	event :cash do
		transition :received, :received_by_treasurer => :cashed
	end
	
end

private

	# Validation du moyen de paiement
	def mean_is_correct
		# Il doit appartenir à la liste suivante :
		@possible_means = ["cheque", "liquid"]

		@possible_means.each do |possible_mean|
			return true if possible_mean == self.mean
		end
		raise "Le moyen de paiement n'est pas correct."
	end

end
