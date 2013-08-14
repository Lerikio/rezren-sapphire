# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
	protect_from_forgery

# Permet d'avoir accès au current_admin pour PublicActivity
	include PublicActivity::StoreController

# Permet de charger différentes méthodes
	include SessionsHelper

# Protège l'application entière des utilisateurs non-connecté
	before_filter :signed_in_admin, :except => [:sessions]

# Permet de vérifier la présence du paramètre archived et de lui donner une valeur si besoin
	before_filter :check_archived_parameter

# Override la méthode de base de CanCan pour utiliser current_admin à la place de current_user
	def current_ability
  		@current_ability ||= Ability.new(current_admin)
	end

	def check_archived_parameter
		unless params[:archived]
			params[:archived] = "false"
		end
	end
end
