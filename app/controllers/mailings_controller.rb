# -*- encoding : utf-8 -*-
class MailingsController < ApplicationController

# Charge @mailing par id, ainsi que les autorisations du controller
load_and_authorize_resource


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
        format.json { render json: @mailing, status: :created, location: @mailing }
      else
        flash.now[:error] = @mailing.errors.full_messages
        format.js { render action: :new}
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
        flash.now[:error] = @mailing.errors.full_messages
        format.js { render action: :edit}
      end
    end
  end

  def destroy
    respond_to do |format|
      # On archive au lieu de supprimer de la base de donnée
      @mailing.update_attribute(:archived, true)
      @mailing.create_activity :destroy, owner: current_admin

      format.html { redirect_to mailings_path, notice: "La mailing a été supprimée." }
      format.json { head :no_content }
    end
  end

  def reload
    @mailings = Mailing.where(:archived => params[:archived].to_bool)
    respond_to do |format|
      format.html { render partial: "index_table" }
    end
  end

end
