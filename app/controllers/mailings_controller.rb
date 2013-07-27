# -*- encoding : utf-8 -*-
class MailingsController < ApplicationController

# Charge @mailing par id, ainsi que les autorisations du controller
load_and_authorize_resource

  # GET /mailings
  # GET /mailings.json
  def index
    @mailings = Mailing.where(:archived => params[:archived].to_bool)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mailings }
    end
  end

  # GET /mailings/1
  # GET /mailings/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mailing }
    end
  end

  # GET /mailings/new
  # GET /mailings/new.json
  def new
    @mailing = Mailing.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mailing }
    end
  end

  # GET /mailings/1/edit
  def edit
  end

  # POST /mailings
  # POST /mailings.json
  def create
    @mailing = Mailing.new(params[:mailing])

    respond_to do |format|
      if @mailing.save

        @mailing.create_activity :create, owner: current_admin

        format.html { redirect_to @mailing, notice: 'Mailing was successfully created.' }
        format.json { render json: @mailing, status: :created, location: @mailing }
      else
        format.html { render action: "new" }
        format.json { render json: @mailing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /mailings/1
  # PUT /mailings/1.json
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

  # DELETE /mailings/1
  # DELETE /mailings/1.json
  def destroy
    # On archive au lieu de supprimer de la base de donnée
    @mailing.update_attribute(:archived, true)
    @mailing.create_activity :destroy, owner: current_admin

    respond_to do |format|
      format.html { redirect_to mailings_url }
      format.json { head :no_content }
    end
  end
end
