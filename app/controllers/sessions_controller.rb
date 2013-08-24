# -*- encoding : utf-8 -*-
class SessionsController < ApplicationController
  skip_before_filter :signed_in_admin, :only => [:new, :create]

  def new
      @admin = Admin.new
      respond_to do |format|
        format.html {render layout: "connexion"}
      end
  end
  
  def create
    if @admin = Admin.authenticate(params[:admin][:username], params[:admin][:password])
      session[:admin_id] = @admin.id
      redirect_to root_path
    else
      redirect_to connexion_path
    end
  end
  
  def destroy
    session[:admin_id] = nil
    redirect_to action: :new
  end
end
