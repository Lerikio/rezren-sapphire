# -*- encoding : utf-8 -*-
Sapphire::Application.routes.draw do

  match '/synchronisation', :to => "switchs_management#synchronisation"
  resources :logs


  resources :roles


	# En vrac
		get '/computers/reload', :controller => 'computers', :action => 'reload'
		resources :computers, :only => [:index, :show]

		get '/payments/reload', :controller => 'payments', :action => 'reload'
		resources :payments do
			member do
				get 'cash'
				get 'by_treasurer'
				get 'reset_status'
			end
		end

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
		get '/adherents/index_discourse', :controller => 'adherents', :action => 'index_discourse'
		resources :adherents do
			member do
				get 'new_discourse'
				put 'create_discourse'
			end
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
