# -*- encoding : utf-8 -*-
class SwitchesController < ApplicationController

# Charge @switch par id, ainsi que les autorisations du controller
load_and_authorize_resource

  # GET /switches
  # GET /switches.json
  def index
    @switches = Switch.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @switches }
    end
  end

  # GET /switches/1
  # GET /switches/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @switch }
    end
  end

  # GET /switches/new
  # GET /switches/new.json
  def new
    @switch = Switch.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @switch }
    end
  end

  # GET /switches/1/edit
  def edit
  end

  # POST /switches
  # POST /switches.json
  def create
    @switch = Switch.new(params[:switch])

    respond_to do |format|
      if @switch.save

        @switch.create_activity :create, owner: current_admin

        format.html { redirect_to @switch, notice: 'Switch was successfully created.' }
        format.json { render json: @switch, status: :created, location: @switch }
      else
        format.html { render action: "new" }
        format.json { render json: @switch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /switches/1
  # PUT /switches/1.json
  def update

    respond_to do |format|
      if @switch.update_attributes(params[:switch])

        @switch.create_activity :update, owner: current_admin

        format.html { redirect_to @switch, notice: 'Switch was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @switch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /switches/1
  # DELETE /switches/1.json
  def destroy
    # On archive au lieu de supprimer de la base de donnée
    @switch.update_attribute(:archived, true)
    @switch.create_activity :destroy, owner: current_admin

    respond_to do |format|
      format.html { redirect_to switches_url }
      format.json { head :no_content }
    end
  end
end
