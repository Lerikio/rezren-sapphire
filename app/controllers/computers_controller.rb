# -*- encoding : utf-8 -*-
class ComputersController < ApplicationController

# Charge @computer par id, ainsi que les autorisations du controller
load_and_authorize_resource nested: :adherent


  def index_all
    @computers = Computer.where(:archived => params[:archived].to_bool)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @computers }
    end

  # GET adherent/id/computers
  # GET /computers.json
  def index
    @computers = Computer.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @computers }
    end
  end

  # GET /computers/1
  # GET /computers/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @computer }
    end
  end

  # GET /computers/new
  # GET /computers/new.json
  def new
    @computer = Computer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @computer }
    end
  end

  # GET /computers/1/edit
  def edit
  end

  # POST /computers
  # POST /computers.json
  def create
    @computer = Computer.new(params[:computer])

    respond_to do |format|
      if @computer.save
 
        @computer.create_activity :create, owner: current_admin

        format.html { redirect_to @computer, notice: 'Computer was successfully created.' }
        format.json { render json: @computer, status: :created, location: @computer }
      else
        format.html { render action: "new" }
        format.json { render json: @computer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /computers/1
  # PUT /computers/1.json
  def update
    respond_to do |format|
      if @computer.update_attributes(params[:computer])

        @computer.create_activity :update, owner: current_admin

        format.html { redirect_to @computer, notice: 'Computer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @computer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /computers/1
  # DELETE /computers/1.json
  def destroy

    # On archive au lieu de supprimer de la base de donnée
    @computer.update_attribute(:archived, true)
    @computer.create_activity :destroy, owner: current_admin

    respond_to do |format|
      format.html { redirect_to computers_url }
      format.json { head :no_content }
    end
  end
end
