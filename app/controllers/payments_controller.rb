# -*- encoding : utf-8 -*-
class PaymentsController < ApplicationController

before_filter :load_adherent

# Charge @payment par id, ainsi que les autorisations du controller
load_and_authorize_resource

  # Get /payments
  def index_all
    @payments = Payment.where(:archived => params[:archived].to_bool)

    respond_to do |format|
      format.html # index_all.html.erb
      format.json { render json: @payments }
    end
  end

  # GET /adherent/id/payments
  # GET /payments.json
  def index
    @payments = Payment.where(:archived => params[:archived].to_bool)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @payments }
    end
  end

  # GET /payments/1
  # GET /payments/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @payment }
    end
  end

  # GET /payments/new
  # GET /payments/new.json
  def new
    @payment = @adherent.credit.payments.build
  end

  # GET /payments/1/edit
  def edit
  end

  # POST /payments
  # POST /payments.json
   def create
    @payment = @adherent.credit.payments.build(params[:payment])
    @payment.admin = current_admin

    respond_to do |format|
      if @payment.save

        @payment.create_activity :create, owner: current_admin
        format.json { render json: @payment, status: :created }
      else        
        flash.now[:error] = @payment.errors.full_messages
        format.js { render action: :new}
      end
    end
  end

  # PUT /payments/1
  # PUT /payments/1.json
  def update

    respond_to do |format|
      if @payment.update_attributes(params[:payment])

        @payment.create_activity :update, owner: current_admin

        format.html { redirect_to @payment, notice: 'Payment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.json
  def destroy

    ## !! IMPORTANT !!
    # Créer un scénario, pour modifier le crédit correspondant en même temps
    # Retirer l'argent

    # On archive au lieu de supprimer de la base de donnée
    @payment.update_attribute(:archived, true)
    @payment.create_activity :destroy, owner: current_admin

    respond_to do |format|
      format.html { redirect_to payments_url }
      format.json { head :no_content }
    end
  end

  private
    def load_adherent
      @adherent = Adherent.find(params[:adherent_id])
    end
end

