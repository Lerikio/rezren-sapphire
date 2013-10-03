# -*- encoding : utf-8 -*-
class Ability
  include CanCan::Ability

  def initialize(current_admin)
  	can :manage, :all
  	#if current_admin.roles.find_by_name('Zero')
   	  #can :read, Adherent
   	  #can :read, Mailing
   	#end
   	#if current_admin.roles.find_by_name('Rezoman')
   	  #can :create, Adherent
   	#end
   	#if current_admin.roles.find_by_name('Tresorier')
   	  #can :manage, Payments
   	#end
   	#if current_admin.roles.find_by_name('Superadmin')
   	  #can :manage, :all
   	#end
  end
end
