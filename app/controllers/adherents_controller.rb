# -*- encoding : utf-8 -*-
class AdherentsController < ApplicationController

# Charge @adherent par id, ainsi que les autorisations du controller
load_and_authorize_resource

  # GET /adherents
  # GET /adherents.json
  def index
    @adherents = Adherent.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @adherents }
    end
  end

  # GET /adherents/1
  # GET /adherents/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @adherent }
    end
  end

  # GET /adherents/new
  # GET /adherents/new.json
  def new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @adherent }
    end
  end

  # GET /adherents/1/edit
  def edit
  end

  # POST /adherents
  # POST /adherents.json
  def create
    @adherent = Adherent.new(params[:adherent])


    respond_to do |format|
      if @adherent.save

        @adherent.create_activity :create, owner: current_admin

        format.html { redirect_to @adherent, notice: 'Adherent was successfully created.' }
        format.json { render json: @adherent, status: :created, location: @adherent }
      else
        format.html { render action: "new" }
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
