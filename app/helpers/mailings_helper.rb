# -*- encoding : utf-8 -*-
module MailingsHelper

	def gen_select2_data
		text = "["
		Adherent.not_archived.each do |adherent|
			text = text + "{id:'#{adherent.email}', text:'#{adherent.email}'},"
		end

		Mailing.not_archived.each do |mailing|
			text = text + "{id:'#{mailing.address}', text:'#{mailing.address}'},"
		end

		text = text + "]"
	end
end
