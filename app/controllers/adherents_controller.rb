# -*- encoding : utf-8 -*-
class AdherentsController < ApplicationController

# Charge @adherent par id, ainsi que les autorisations du controller
load_and_authorize_resource except: :create
authorize_resource only: :create

  def index
    @adherents = Adherent.where(:archived => params[:archived].to_bool)
  end

  def show
  end

  def new
    @computer = @adherent.computers.build
    @computer_dns_entry = @computer.build_computer_dns_entry
    
    @credit = @adherent.build_credit
    @credit.payments.build
  end

  def edit
    @adherent.computers.build
    @adherent.credit.build
  end

  def create

    @room = Room.find_by_id(params[:adherent][:room])
    params[:adherent].delete :room

    @adherent = Adherent.new(params[:adherent])


    respond_to do |format|
      if @adherent.save

        @room.adherent = @adherent
        @romm.save

        @adherent.create_activity :create, owner: current_admin

        format.html { redirect_to @adherent, notice: 'Adherent was successfully created.' }
        format.json { render json: @adherent, status: :created, location: @adherent }
      else
        format.json { render json: @adherent.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /adherents/1
  # PUT /adherents/1.json
  def update

    respond_to do |format|
      if @adherent.update_attributes(params[:adherent])

        @adherent.create_activity :update, owner: current_admin

        format.html { redirect_to @adherent, notice: 'Adherent was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @adherent.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /adherents/1
  # DELETE /adherents/1.json
  def destroy
    # On archive au lieu de supprimer de la base de donnée
    @adherent.update_attribute(:archived, true)

    @adherent.create_activity :destroy, owner: current_admin

    respond_to do |format|
      format.html { redirect_to adherents_url }
      format.json { head :no_content }
    end
  end
end
