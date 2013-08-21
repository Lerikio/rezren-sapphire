# -*- encoding : utf-8 -*-
module SessionsHelper

	def current_admin
		@current_admin ||= Admin.find(session[:admin_id]) if session[:admin_id]
	end

	def signed_in_admin
    	redirect_to connexion_path, notice: "Veuillez vous connecter." unless signed_in?
    end

    def signed_in?
    	!current_admin.nil?
    end
end
