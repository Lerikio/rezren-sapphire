# -*- encoding : utf-8 -*-
class CreditController < ApplicationController

# Charge @credit par id, ainsi que les autorisations du controller
load_and_authorize_resource

  def destroy
    # On archive au lieu de supprimer de la base de donnée
    @credit.update_attribute(:archived, true)
  end

end
