# -*- encoding : utf-8 -*-
module ActivitiesHelper
	#Pour l'eager loading
	def payment_from_trackable(trackable)
		@payments.detect{|p| p.id == trackable.id}
	end
end
