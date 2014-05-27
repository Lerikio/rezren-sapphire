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
# 	Mise à jour de la date de fin d'adhésion -- à appeler par les paiements
# --------------------------------------------------------------------------------------------------

	# Permet de recalculer la date de fin d'adhésion en fonction de tous les paiements enregistrés dans la BDD et de leurs dates de dépôt.
	def update_end_of_adhesion
		self.end_of_adhesion = Time.new(1997, 4, 11)

		self.active_payments.sort_by{|p| p[:created_at]}.each do |p|
						
			if self.end_of_adhesion > p.created_at
				self.end_of_adhesion += p.time_value.days
			else
				self.end_of_adhesion = p.created_at + p.time_value.days
			end
		end
	end

####################################################################################################
#
#                                            Helpers	  
#
####################################################################################################


	def value
		(self.end_of_adhesion - Date.today).to_i*Monthly_cotisation/30.0
	end

	def time_value
		(self.end_of_adhesion - Date.today).to_i.to_s + " jours"
		#if self.end_of_adhesion < Date.today then "0 jour" end
		#ligne commentée pendant les tests avant production => permet de savoir de combien on a dépassé la date d'expiration
	end

	def actif?
		Date.today < self.end_of_adhesion || adherent.rezoman
	end

	def should_be_disconnected?
		not actif?
	end
end
