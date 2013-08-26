# -*- encoding : utf-8 -*-
class Credit < ActiveRecord::Base

# Cotisation mensuelle en euros
	Monthly_cotisation = 6

scope :not_archived, -> { where(archived: false)}

attr_accessible :payments_attributes

# Attributs et associations	

	has_many :payments, inverse_of: :credit
	belongs_to :adherent, dependent: :destroy, inverse_of: :credit

	# Permet de stocker une HashMap dans la base de donnée
	serialize :history, Hash

# Validations

	validates :adherent, presence: true

# Nested attributes
	accepts_nested_attributes_for :payments


####################################################################################################
#
#                                Méthodes de gestion du crédit 	  
#
####################################################################################################

# --------------------------------------------------------------------------------------------------
# 	Mise à jour de la date de prochain débit -- à appeler par les paiements
# --------------------------------------------------------------------------------------------------

	def update_next_debit(archived)
		unless archived
			if last_payment.created_at.to_date >= next_debit
				next_debit = last_payment.created_at.to_date + 1.month
			end
		end
	end

# --------------------------------------------------------------------------------------------------
# 	Mise à jour de la date de fin d'adhésion -- à appeler par les paiements
# --------------------------------------------------------------------------------------------------

	def update_end_of_adhesion(payment, archived)
		value_to_add = payment.value
		number_of_months = value_to_add / Monthly_cotisation
		number_of_days = value_to_add / (Monthly_cotisation/30.0)
		total_time = number_of_days.days + number_of_months.months

		if archived
			end_of_adhesion -= total_time
		else
			if end_of_adhesion <= Date.today
				end_of_adhesion = total_time.from_now
			else
				end_of_adhesion += total_time
			end
		end
	end

####################################################################################################
#
#                                            Helpers	  
#
####################################################################################################


	def value
		payments.not_archived.sum{|i| i.value} - debited_value
	end

	def actif?
		Date.today < next_debit + 1.month || adherent.rezoman
	end

	def should_be_disconnected?
		not actif?
	end
end