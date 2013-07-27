# -*- encoding : utf-8 -*-
class VlansController < ApplicationController

# Charge @vlan par id, ainsi que les autorisations du controller
load_and_authorize_resource

  # GET /vlans
  # GET /vlans.json
  def index
    @vlans = Vlan.where(:archived => params[:archived].to_bool)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @vlans }
    end
  end

  # GET /vlans/1
  # GET /vlans/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @vlan }
    end
  end

  # GET /vlans/new
  # GET /vlans/new.json
  def new
    @vlan = Vlan.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @vlan }
    end
  end

  # GET /vlans/1/edit
  def edit
  end

  # POST /vlans
  # POST /vlans.json
  def create
    @vlan = Vlan.new(params[:vlan])

    respond_to do |format|
      if @vlan.save

        @vlan.create_activity :create, owner: current_admin

        format.html { redirect_to @vlan, notice: 'Vlan was successfully created.' }
        format.json { render json: @vlan, status: :created, location: @vlan }
      else
        format.html { render action: "new" }
        format.json { render json: @vlan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /vlans/1
  # PUT /vlans/1.json
  def update

    respond_to do |format|
      if @vlan.update_attributes(params[:vlan])

        @vlan.create_activity :update, owner: current_admin

        format.html { redirect_to @vlan, notice: 'Vlan was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @vlan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vlans/1
  # DELETE /vlans/1.json
  def destroy
    # On archive au lieu de supprimer de la base de donnée
    @vlan.update_attribute(:archived, true)
    @vlan.create_activity :destroy, owner: current_admin

    respond_to do |format|
      format.html { redirect_to vlans_url }
      format.json { head :no_content }
    end
  end
end
