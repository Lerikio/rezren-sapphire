# -*- encoding : utf-8 -*-
class SwitchesController < ApplicationController

# Charge @switch par id, ainsi que les autorisations du controller
load_and_authorize_resource except: :create
authorize_resource only: :create

  # GET /switches
  # GET /switches.json
  def index
    @switches = Switch.includes({ports: :room}).where(:archived => params[:archived].to_bool)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @switches }
    end
  end

  def show
  end

  def new
  end

  def edit
    @switch = Switch.find(params[:id], :include => {:ports => :room })
    #Pour éviter des requêtes SQL
    @not_archived_rooms = Room.not_archived
  end

  def create
    
    number_of_ports = params[:switch][:number_of_ports]
    params[:switch].delete :number_of_ports

    @switch = Switch.new(params[:switch])

    respond_to do |format|
      if @switch.valid? 

        ActiveRecord::Base.transaction do
          @switch.save  
          if number_of_ports.to_i >= 1
            for number in 1..number_of_ports.to_i
              @switch.ports.build(number: number).save
            end
          end
        end

        @switch.create_activity :create, owner: current_admin
        format.json { render json: @switch, status: :created, location: @switch }
      else        
        flash.now[:error] = @switch.errors.full_messages
        format.js { render action: :new}
      end  
    end
  end

  # PUT /switches/1
  # PUT /switches/1.json
  def update
    params[:switch][:ports_attributes].each do |port_number|
      params[:switch][:ports_attributes][port_number[0]][:room] = Room.find_by_id(params[:switch][:ports_attributes][port_number[0]][:room])
    end
    respond_to do |format|
      if @switch.update_attributes(params[:switch])

        @switch.create_activity :update, owner: current_admin

        format.js { head :no_content }
        format.html { redirect_to @switch, notice: 'Switch was successfully updated.' }
        format.json { head :no_content }
      else
        flash.now[:error] = @mailing.errors.full_messages
        format.js { render action: :edit}
      end
    end
  end

  # DELETE /switches/1
  # DELETE /switches/1.json
  def destroy
    respond_to do |format|
      # On archive au lieu de supprimer de la base de donnée
      @switch.update_attribute(:archived, true)
      @switch.create_activity :destroy, owner: current_admin

      format.html { redirect_to switches_url }
      format.json { head :no_content }
    end
  end

  def reload
    @switches = Switch.where(:archived => params[:archived].to_bool)
    respond_to do |format|
      format.html { render partial: "index_table" }
    end
  end
end