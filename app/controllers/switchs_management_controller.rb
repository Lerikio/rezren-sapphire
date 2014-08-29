class SwitchsManagementController < ApplicationController

require SwitchsManagementHelper

  def synchronisation
	render 'synchronisation'
	synchronisation_affichage
  end
end
