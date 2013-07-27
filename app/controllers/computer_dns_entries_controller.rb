# -*- encoding : utf-8 -*-
class ComputerDnsEntriesController < ApplicationController

# Charge @computer_dns_entry par id, ainsi que les autorisations du controller
load_and_authorize_resource

  # GET /computer_dns_entries
  # GET /computer_dns_entries.json
  def index
    @computer_dns_entries = ComputerDnsEntry.where(:archived => params[:archived].to_bool)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @computer_dns_entries }
    end
  end

  # GET /computer_dns_entries/1
  # GET /computer_dns_entries/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @computer_dns_entry }
    end
  end

  # GET /computer_dns_entries/new
  # GET /computer_dns_entries/new.json
  def new
    @computer_dns_entry = ComputerDnsEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @computer_dns_entry }
    end
  end

  # GET /computer_dns_entries/1/edit
  def edit
  end

  # POST /computer_dns_entries
  # POST /computer_dns_entries.json
  def create
    @computer_dns_entry = ComputerDnsEntry.new(params[:computer_dns_entry])

    respond_to do |format|
      if @computer_dns_entry.save

        @computer_dns_entry.create_activity :create, owner: current_admin

        format.html { redirect_to @computer_dns_entry, notice: 'Computer dns entry was successfully created.' }
        format.json { render json: @computer_dns_entry, status: :created, location: @computer_dns_entry }
      else
        format.html { render action: "new" }
        format.json { render json: @computer_dns_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /computer_dns_entries/1
  # PUT /computer_dns_entries/1.json
  def update

    respond_to do |format|
      if @computer_dns_entry.update_attributes(params[:computer_dns_entry])
        
        @computer_dns_entry.create_activity :update, owner: current_admin

        format.html { redirect_to @computer_dns_entry, notice: 'Computer dns entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @computer_dns_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /computer_dns_entries/1
  # DELETE /computer_dns_entries/1.json
  def destroy
    # On archive au lieu de supprimer de la base de donnée
    @computer_dns_entry.update_attribute(:archived, true)
    @computer_dns_entry.create_activity :destroy, owner: current_admin

    respond_to do |format|
      format.html { redirect_to computer_dns_entries_url }
      format.json { head :no_content }
    end
  end
end
