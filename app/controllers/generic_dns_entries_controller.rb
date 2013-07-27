# -*- encoding : utf-8 -*-
class GenericDnsEntriesController < ApplicationController

# Charge @generic_dns_entry par id, ainsi que les autorisations du controller
load_and_authorize_resource 

  # GET /generic_dns_entries
  # GET /generic_dns_entries.json
  def index
    @generic_dns_entries = GenericDnsEntry.where(:archived => params[:archived].to_bool)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @generic_dns_entries }
    end
  end

  # GET /generic_dns_entries/1
  # GET /generic_dns_entries/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @generic_dns_entry }
    end
  end

  # GET /generic_dns_entries/new
  # GET /generic_dns_entries/new.json
  def new
    @generic_dns_entry = GenericDnsEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @generic_dns_entry }
    end
  end

  # GET /generic_dns_entries/1/edit
  def edit
  end

  # POST /generic_dns_entries
  # POST /generic_dns_entries.json
  def create
    @generic_dns_entry = GenericDnsEntry.new(params[:generic_dns_entry])

    respond_to do |format|
      if @generic_dns_entry.save

        @generic_dns_entry.create_activity :create, owner: current_admin

        format.html { redirect_to @generic_dns_entry, notice: 'Generic dns entry was successfully created.' }
        format.json { render json: @generic_dns_entry, status: :created, location: @generic_dns_entry }
      else
        format.html { render action: "new" }
        format.json { render json: @generic_dns_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /generic_dns_entries/1
  # PUT /generic_dns_entries/1.json
  def update

    respond_to do |format|
      if @generic_dns_entry.update_attributes(params[:generic_dns_entry])

        @generic_dns_entry.create_activity :update, owner: current_admin

        format.html { redirect_to @generic_dns_entry, notice: 'Generic dns entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @generic_dns_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /generic_dns_entries/1
  # DELETE /generic_dns_entries/1.json
  def destroy
    # On archive au lieu de supprimer de la base de donnée
    @generic_dns_entry.update_attribute(:archived, true)
    @generic_dns_entry.create_activity :destroy, owner: current_admin

    respond_to do |format|
      format.html { redirect_to generic_dns_entries_url }
      format.json { head :no_content }
    end
  end
end
