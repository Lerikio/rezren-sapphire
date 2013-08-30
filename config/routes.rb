# -*- encoding : utf-8 -*-
Sapphire::Application.routes.draw do

  resources :logs


  resources :roles


	# En vrac
		# Permet de visualiser la totalité des instances d'un modèle malgré une nested_route
		resources :computers, :only => [:index, :show]
		get "payments", to: "payments#index_all", as: "payments"

		# Sessions
		delete "deconnexion", to: "sessions#destroy", as: "deconnexion"
		get 'connexion', to: 'sessions#new', as: :connexion

		root to: "activities#index"

	# Les différentes ressources de l'appli

		resources :sessions
		resources :admins

		get '/mailings/reload', :controller => 'mailings', :action => 'reload'
		resources :mailings

		get '/rooms/reload', :controller => 'rooms', :action => 'reload'
		resources :rooms

		get '/adherents/reload', :controller => 'adherents', :action => 'reload'
		resources :adherents do
			resources :computers
			resources :payments
			get "credit/destroy"
		end
		
		get '/generic_dns_entries/reload', :controller => 'generic_dns_entries', :action => 'reload'
	  	resources :generic_dns_entries
	  	resources :computer_dns_entries do
			resources :alias_dns_entries
		end
		resources :vlans

		get '/switches/reload', :controller => 'switches', :action => 'reload'
		resources :switches do
			resources :ports
		end
	
end