# -*- encoding : utf-8 -*-
class Switch < ActiveRecord::Base

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Attributs et associations	

	attr_accessible :community, :ip_admin

	has_many :ports, dependent: :destroy

# Validations

	validates :community, presence: true
	validates :ip_admin, presence: true, uniqueness: true


	#Renvoie une interface SNMP pour manager le switch/wifiAp à distance
    def snmp_interface(options={})
      if @interface
        return @interface
      else
        #interfaceClass=(self.read_attribute(:model) + "_interface").camelize.constantize
        #@interface=interfaceClass.new(ip)
        #return @interface

        @interface=DummyInterface.new
      end
    end
end
