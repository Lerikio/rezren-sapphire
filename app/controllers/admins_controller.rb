# -*- encoding : utf-8 -*-
class AdminsController < ApplicationController

# Charge @admin par id, ainsi que les autorisations du controller
load_and_authorize_resource

	def index
		@admins = Admin.all
	end

	def show
	end

	def new
	end

	def create
		@admin = Admin.new(params[:admin])
		if @admin.save

			@admin.create_activity :create, owner: current_admin

			redirect_to root_path, notice: "L'administrateur a été créé."
		else
			render "new"
	end

	def edit
	end

	def update
		if @admin.update_attributes(params[:admin])

			@admin.create_activity :update, owner: current_admin
			
			redirect_to @admin, notice: "L'administrateur a été mis à jour."
		else
			render action: "edit"
		end
	end

	def destroy
    	# On archive au lieu de supprimer de la base de donnée
   		@admin.update_attribute(:archived, true)

		@admin.create_activity :destroy, owner: current_admin

		redirect_to admins_path, notice: "L'administrateur a été supprimé."
	end
end
