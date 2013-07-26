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
    @admin = Admin.find_by_username(params[:admin][:username])
    if @admin && Admin.authenticate(params[:admin][:username], params[:admin][:password])
      session[:admin_id] = @admin.id
      redirect_to activity_path
    else
      redirect_to new_session_path
    end
  end
  
  def destroy
    session[:admin_id] = nil
    redirect_to root_path
  end
end
