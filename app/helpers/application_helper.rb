# -*- encoding : utf-8 -*-
module ApplicationHelper

  # Permet de donner un titre à chaque page, contenant Sapphire
    def full_title(page_title)
      base_title = "Sapphire"
      if page_title.empty?
        base_title
      else
        "#{page_title} | #{base_title}"
      end
    end

   # Ajoute la fonction bootstrap_flash normalement incluse dans bootstrap (en LESS)
    ALERT_TYPES = [:error, :info, :success, :warning]

	def bootstrap_flash
	    flash_messages = []
	    flash.each do |type, message|
		    # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
		    next if message.blank?
		    
		    type = :success if type == :notice
		    type = :error   if type == :alert
		    next unless ALERT_TYPES.include?(type)

		    Array(message).each do |msg|
		      text = content_tag(:div,
		                         content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
		                         msg.html_safe, :class => "alert fade in alert-#{type}")
		      flash_messages << text if msg
		    end
	    end
	    flash_messages.join("\n").html_safe
	end

end
