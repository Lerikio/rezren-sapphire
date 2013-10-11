# -*- encoding : utf-8 -*-
class ActivitiesController < ApplicationController

  def index
  	PublicActivity::Activity.includes(:owner, [:trackable => :adherent]).limit(200).find_all_by_trackable_type("Payment")
  	@activities = PublicActivity::Activity.includes(:owner, :trackable).limit(200).order("created_at desc")
  end
end
