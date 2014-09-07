# -*- encoding : utf-8 -*-
class Switch < ActiveRecord::Base

scope :not_archived, -> { where(archived: false)}

# Surveillance par la gem public_activity
	include PublicActivity::Common

# Bibliothèques netconf
	require 'pp'
	require 'net/netconf/jnpr'
	require 'junos-ez/stdlib'

# Attributs et associations	

	attr_accessible :community, :ip_admin, :description,
                    :ports_attributes
  attr_accessor :number_of_ports #Permet à l'utilisateur de rentrer le nombre de ports à créer pour le switch

	has_many :ports, dependent: :destroy, inverse_of: :switch

# Validations

	validates :community, presence: true
	validates :ip_admin, presence: true, uniqueness: true
  validates :description, presence: true

  accepts_nested_attributes_for :ports


  def occupied_ports_count
    number_of_occupied_ports = 0
    self.ports.each do |port|
      unless port.room == nil
        number_of_occupied_ports += 1
      end
    end
    number_of_occupied_ports
  end

	#Renvoie une interface SNMP pour manager le switch/wifiAp à distance
    def snmp_interface(options={})
      if @interface
        return @interface
      else
        #interfaceClass=(self.read_attribute(:model) + "_interface").camelize.constantize
        #@interface=interfaceClass.new(ip)
        #return @interface

        @interface = NetgearInterface.new(self.ip_admin, self.community)
      end
    end

    def connect_by_netconf
	login = { :target => self.ip_admin, :username => "root", :password => "abc123" }
	#Ouverture de session
	session = Netconf::SSH::new(login)

	if(session.open())
		#Chargement des fonctions nécessaires
		Junos::Ez::Provider(session) #Fonctionnalités de base : version firmware ...
		Junos::Ez::L1ports::Provider(session, :l1_ports) #Management des ports physiques
		Junos::Ez::L2ports::Provider(session, :l2_ports) #Management couche 2
		Junos::Ez::Vlans::Provider(session, :vlans) #Management des vlans
		Junos::Ez::Config::Utils(session, :cu) # Fonctions nécessaires au commit
	else
		puts "Erreur lors de la connection vers " + self.ip_admin.to_s
	end

	session
    end

    def disconnect_by_netconf(session)
	if(session)
		puts "Fermeture..."
		session.close
		puts "Fermé."
	end
    end

    def connected_by_netconf?(session)
	begin
		if(session.facts.read! != nil)
			true
		end
	rescue 
		false 
	end
    end

    def get_config_BDD
        config = Array.[]
        
        this.ports.each do |p|
            #Status admin des ports
            #A modifier lorsque le prerezotage sera disponible.
            conf_port[:admin_status] = p.room.adherent.actif?

            #Vlan
            conf_port[:vlan_id] = p.get_authorized_vlan
            
            #Mac
            p.room.adherent.computers.each do |computer|
                conf_port[:mac_addresses] << computer.mac_address
            end
            
            config << conf_port
        end
        config
    end

    def commit_modifs_by_netconf(session)
	if (session.cu.commit?)
		if (session.cu.commit!)
			puts "Commit réussi"
		else
			puts "Echec du commit"
		end
	else
		puts "Les données à commiter sont invalides"
	end
    end

end
