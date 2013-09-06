# -*- encoding : utf-8 -*-
class RoomsController < ApplicationController
  include RoomsHelper

  before_filter :load_buildings

# Charge @room par id, ainsi que les autorisations du controller
  load_and_authorize_resource

  def index
    @rooms = Room.includes(:adherent, {port: :switch}).where(:archived => params[:archived].to_bool)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rooms }
    end
  end


  def show
  end

  def new
  end

  def edit
  end

  def create
    @room = Room.new(params[:room])

    respond_to do |format|
      if @room.save

        @room.create_activity :create, owner: current_admin
        format.json { render json: @rooms, status: :created, location: @rooms }
      else
        flash.now[:error] = @room.errors.full_messages
        format.js { render action: :new}
      end
    end
  end

  def update
    respond_to do |format|
      if @room.update_attributes(params[:room])

        @room.create_activity :update, owner: current_admin

        format.js { head :no_content }
        format.html { redirect_to @room, notice: 'Room was successfully updated.' }
        format.json { head :no_content }
      else
        flash.now[:error] = @room.errors.full_messages
        format.js { render action: :edit}
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    # On archive au lieu de supprimer de la base de donnée

    respond_to do |format|
      @room.update_attribute(:archived, true)
      @room.create_activity :destroy, owner: current_admin
      format.html { redirect_to rooms_url }
      format.json { head :no_content }
    end
  end

  def reload
    @rooms = Room.where(:archived => params[:archived].to_bool)
    respond_to do |format|
      format.html { render partial: "index_table" }
    end
  end
end
