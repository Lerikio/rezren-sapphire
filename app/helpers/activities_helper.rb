# -*- encoding : utf-8 -*-
module ActivitiesHelper
	#Pour l'eager loading
	def payment_from_trackable(trackable)
		payment = @payments.detect{|p| p.trackable.id == trackable.id}
		payment.id
	end
end
