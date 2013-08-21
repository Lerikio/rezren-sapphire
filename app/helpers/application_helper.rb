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


  def formatted_amount(value)
    return value.round(2).to_s if value <= 100
    return value.to_i.to_s if value > 100 && value <= 1000
    return number_to_currency(value / 1000.0, {:unit => '', :separator => ',', :delimiter => ' ', :precision => 2, :negative_format => "-%n%u"}).to_s + "k" if value > 1000
  end
  
  def formatted_amount_with_currency(value)
    formatted_amount(value) + '€'
  end
<<<<<<< HEAD

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end
=======
>>>>>>> 6d299dfb9b0a4c3197311b60d44d613cd23cfd8f
  
end
