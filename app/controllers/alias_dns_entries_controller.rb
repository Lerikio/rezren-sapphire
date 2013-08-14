# -*- encoding : utf-8 -*-
class AliasDnsEntriesController < ApplicationController

# Charge @alias_dns_entry par id, ainsi que les autorisations du controller
load_and_authorize_resource

  # GET /alias_dns_entries
  # GET /alias_dns_entries.json
  def index
    @alias_dns_entries = AliasDnsEntry.where(:archived => params[:archived].to_bool)
  end

  # GET /alias_dns_entries/1
  # GET /alias_dns_entries/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @alias_dns_entry }
    end
  end

  # GET /alias_dns_entries/new
  # GET /alias_dns_entries/new.json
  def new
    @alias_dns_entry = AliasDnsEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @alias_dns_entry }
    end
  end

  # GET /alias_dns_entries/1/edit
  def edit
  end

  # POST /alias_dns_entries
  # POST /alias_dns_entries.json
  def create
    @alias_dns_entry = AliasDnsEntry.new(params[:alias_dns_entry])

    respond_to do |format|
      if @alias_dns_entry.save

        @alias_dns_entry.create_activity :create, owner: current_admin

        format.html { redirect_to @alias_dns_entry, notice: 'Alias dns entry was successfully created.' }
        format.json { render json: @alias_dns_entry, status: :created, location: @alias_dns_entry }
      else
        format.html { render action: "new" }
        format.json { render json: @alias_dns_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /alias_dns_entries/1
  # PUT /alias_dns_entries/1.json
  def update

    respond_to do |format|
      if @alias_dns_entry.update_attributes(params[:alias_dns_entry])
        
        @alias_dns_entry.create_activity :update, owner: current_admin

        format.html { redirect_to @alias_dns_entry, notice: 'Alias dns entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @alias_dns_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /alias_dns_entries/1
  # DELETE /alias_dns_entries/1.json
  def destroy
    # On archive au lieu de supprimer de la base de donnée
    @alias_dns_entry.update_attribute(:archived, true)
    @alias_dns_entry.create_activity :destroy, owner: current_admin

    respond_to do |format|
      format.html { redirect_to alias_dns_entries_url }
      format.json { head :no_content }
    end
  end
end
