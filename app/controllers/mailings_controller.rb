# -*- encoding : utf-8 -*-
class MailingsController < ApplicationController

# Charge @mailing par id, ainsi que les autorisations du controller
load_and_authorize_resource

# Autocompletion pour les adherents

  def index
      @mailings = Mailing.where(:archived => params[:archived].to_bool)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @mailing = Mailing.new(params[:mailing])

    respond_to do |format|
      if @mailing.save

        @mailing.create_activity :create, owner: current_admin

        format.html { redirect_to mailings_url, notice: 'Mailing was successfully created.' }
      else
        format.json { render json: @mailing.errors, status: :unprocessable_entity }
      end
    end
  end

  def update

    respond_to do |format|
      if @mailing.update_attributes(params[:mailing])

        @mailing.create_activity :update, owner: current_admin

        format.html { redirect_to @mailing, notice: 'Mailing was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mailing.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # On archive au lieu de supprimer de la base de donnée
    @mailing.update_attribute(:archived, true)
    @mailing.create_activity :destroy, owner: current_admin
  end

end
