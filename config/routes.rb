# -*- encoding : utf-8 -*-
Sapphire::Application.routes.draw do

  resources :roles


	# En vrac
		# Permet de visualiser la totalité des instances d'un modèle malgré une nested_route
		get "computers", to: "computers#index", as: "computers"
		get "payments", to: "payments#index_all", as: "payments"

		# Sessions
		delete "deconnexion", to: "sessions#destroy", as: "deconnexion"
		get 'connexion', to: 'sessions#new', as: :connexion

		root to: "activities#index"

	# Les différentes ressources de l'appli

		resources :sessions
		resources :admins

		resources :mailings
		resources :rooms

		resources :adherents do
			resources :computers
			resources :payments
			get "credit/destroy"
		end

	  	resources :generic_dns_entries
	  	resources :computer_dns_entries do
			resources :alias_dns_entries
		end
		resources :vlans

		resources :switches do
			resources :ports
		end
	
end