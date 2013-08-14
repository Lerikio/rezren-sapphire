# -*- encoding : utf-8 -*-
Sapphire::Application.routes.draw do

  resources :roles


	# En vrac
		get "activity", to: "activities#index", as: "activity"

		# Permet de visualiser la totalité des instances d'un modèle malgré une nested_route
		get "computers", to: "computers#index", as: "computers"
		get "payments", to: "payments#index", as: "payments"

		# Vide la session
		delete "deconnexion", to: "sessions#destroy", as: "deconnexion"

		# Autocompletions
		get "autocomplete_adherent_full_name", to: "adherents#autocomplete_adherent_full_name", as: "autocomplete_adherent_full_name"


		root to: "sessions#new"

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
	

# Redirection vers les autres services du serveur
	# Rediriger vers rezowiki
	match "/rezowiki" => redirect("/rezowiki/index.php"), :as => :rezowiki

	# Rediriger vers phpmyadmin
	match "/phpmyadmin" => redirect("/phpmyadmin/index.php"), :as => :phpmyadmin

end