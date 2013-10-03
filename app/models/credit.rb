# -*- encoding : utf-8 -*-
class Credit < ActiveRecord::Base

# Cotisation mensuelle en euros
	Monthly_cotisation = 6

attr_accessible :payments_attributes

# Attributs et associations	

	has_many :payments, inverse_of: :credit
	has_many :active_payments, :class_name => "Payment", :conditions => {:archived => false}
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

	def update_next_debit
		if !self.next_debit or self.next_debit < Date.today or self.next_debit > Date.today + 1.month
			self.next_debit = 1.month.from_now
		else
			self.next_debit += 1.month
			if self.next_debit > self.end_of_adhesion
				self.next_debit = self.end_of_adhesion
			end
		end
	end

# --------------------------------------------------------------------------------------------------
# 	Mise à jour de la date de fin d'adhésion -- à appeler par les paiements
# --------------------------------------------------------------------------------------------------

	def update_end_of_adhesion
		number_of_months = (self.value / Monthly_cotisation).to_i
		number_of_days = ((self.value - number_of_months * Monthly_cotisation) / (Monthly_cotisation/30.0)).to_i
		total_time = number_of_days.days + number_of_months.months

		self.end_of_adhesion = self.next_debit + total_time - 1.month
	end

	def debit_cotisation
		if self.next_debit <= Date.today
			self.debited_value += [Monthly_cotisation, self.value].min
			self.update_next_debit
			self.update_end_of_adhesion
		end
	end

####################################################################################################
#
#                                            Helpers	  
#
####################################################################################################


	def value
		self.active_payments.sum{|i| i.value} - debited_value
	end

	def actif?
		Date.today < self.end_of_adhesion || adherent.rezoman
	end

	def should_be_disconnected?
		not actif?
	end
end