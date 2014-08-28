# encoding : UTF-8



namespace :netconf do

	require "#{Rails.root}/app/helpers/switchs_management_helper"
	include SwitchsManagementHelper 

	desc "Test synchronisation"
	task :synchronisation => :environment do
		synchronisation
	end
end
