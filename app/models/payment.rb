# -*- encoding : utf-8 -*-
class Payment < ActiveRecord::Base

scope :not_archived, -> { where(archived: false)}

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	

	attr_accessible :comment, :mean, :paid_value, :value, :bank_name, :cotisation

	belongs_to :credit, inverse_of: :payments
	belongs_to :admin, inverse_of: :payments
	has_one :adherent, through: :credit


# Validations

	validates :value, presence: true
	validates :paid_value, presence: true

	validates :comment, presence: true, unless: :equality_of_values

	validate :mean_is_correct
	validates :bank_name, presence: true, if: :mean_is_cheque

	validates :credit, presence: true
	validates :admin, presence: true

# Lors de la sauvegarde :
	after_save :update_credit

# Machine d'état

state_machine :state, initial: :received do

	after_transition all => :cashed, do: :set_cached_date

	event :by_treasurer do
		transition :received => :received_by_treasurer
	end
	
	event :cash do
		transition [:received, :received_by_treasurer] => :cashed
	end

	event :reset_status do
		transition [:cashed, :received_by_treasurer] => :received
	end
	
end

	def mean_is_cheque
		mean == "cheque"
	end

	def save_current_cotisation
		if cotisation == nil then cotisation = Credit::Monthly_cotisation end
	end

	def time_value
		value*31.0/Credit::Monthly_cotisation
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

	def equality_of_values
		paid_value == value
	end

	def set_cached_date
		self.cashed_date = Time.now
	end

	# Mise à jour du crédit de l'utilisateur lors de la création du paiement
	def update_credit
		credit.update_end_of_adhesion
		credit.save
	end

end
