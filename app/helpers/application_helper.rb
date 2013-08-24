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
	    flash_messages_error = []
      flash_messages_success = []
	    flash.each do |type, message|
		    # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
		    next if message.blank?
		    
		    type = :success if type == :notice
		    type = :error   if type == :alert
		    next unless ALERT_TYPES.include?(type)

		    Array(message).each do |msg|
		      text = content_tag(:span, msg.html_safe)
		      flash_messages_error << text if msg && type == :error
          flash_messages_success << text if msg && type == :success
		    end
	    end
	    errors = content_tag(:div,
                     content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                     flash_messages_error.join("</br>\n").html_safe, :class => "alert fade in alert-error") if flash_messages_error.any?
      success = content_tag(:div,
                     content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                     flash_messages_success.join("</br>\n").html_safe, :class => "alert fade in alert-success") if flash_messages_success.any?
      errors + "\n" + success
	end


  def formatted_amount(value)
    return value.round(2).to_s if value <= 100
    return value.to_i.to_s if value > 100 && value <= 1000
    return number_to_currency(value / 1000.0, {:unit => '', :separator => ',', :delimiter => ' ', :precision => 2, :negative_format => "-%n%u"}).to_s + "k" if value > 1000
  end
  
  def formatted_amount_with_currency(value)
    formatted_amount(value) + '€'
  end
  
end
