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

    @credit = @adherent.build_credit
    @credit.payments.build
  end


  def create

    params[:adherent][:room] = Room.find_by_id(params[:adherent][:room])
    #params[:adherent].delete :room

    @adherent = Adherent.new(params[:adherent])
    @adherent.credit.payments.first.admin = current_admin if @adherent.credit

    respond_to do |format|
      if @adherent.save

        @adherent.create_activity :create, owner: current_admin
        format.json { render json: @adherent, status: :created, location: @adherent }
      else        
        flash.now[:error] = @adherent.errors.full_messages

        @adherent.computers.build if @adherent.computers.empty?
        @computer = @adherent.computers.first

        @adherent.build_credit unless @adherent.credit
        @credit = @adherent.credit
        @credit.payments.build if @credit.payments.empty?
        format.js { render action: :new}
      end  
    end
  end


  def edit
  end

  def update
    @room = Room.find_by_id(params[:adherent][:room])
    params[:adherent].delete :room

    respond_to do |format|
      if @adherent.update_attributes(params[:adherent])

        if @room
          @room.adherent = @adherent
          @romm.save
        end
        
        @adherent.create_activity :update, owner: current_admin
        format.json { render json: @adherent, status: :updated, location: @adherent }
      else        
        flash.now[:error] = @adherent.errors.full_messages
        format.js { render :edit}
      end  
    end
  end

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
