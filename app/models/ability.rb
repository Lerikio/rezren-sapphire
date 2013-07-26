# -*- encoding : utf-8 -*-
class Ability
  include CanCan::Ability

  def initialize(current_admin)
    can :manage, :all
  end
end
