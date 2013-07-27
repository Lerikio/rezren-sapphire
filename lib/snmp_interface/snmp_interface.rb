class SnmpInterface
  require 'snmp'
  include SNMP

  attr_reader :ip, :model

  def initialize(ip, options = {})
    @ip = ip
    @manager = Manager.new(:Version => :SNMPv1, :Host => @ip, :Port => 161, :Community => "private")
    @vlans_ids = options[:vlans_ids] if options[:vlans_ids]
    @bridges = options[:bridges] if options[:bridges]
    @model = self.get_model
    return true
  end


  #--
  # MODEL, NAME, DESCRIPTION, CONTACT, LOCATION & UPTIME
  #++


  # Renvoie le nom du switch tel que défini dans sa mémoire interne.
  def get_name
    get_oid(OID_SYS_NAME) 
  end

  # Définit le champ "nom" de la mémoire interne du switch
  def set_name(value)
    set_oid(OID_SYS_NAME,value, OctetString) 
  end

  # Renvoie l'adresse de l'administrateur telle que définie dans la mémoire interne du switch
  def get_contact
    get_oid(OID_SYS_CONTACT) 
  end

  # Définit le champ "adresse de l'administrateur" de la mémoire interne du switch
  def set_contact(value)
    set_oid(OID_SYS_CONTACT, value, OctetString)
  end

  # Renvoie la localisation du switch telle que définie dans sa mémoire interne.
  def get_location
    get_oid(OID_SYS_LOCATION)
  end

  # Définit le champ "localisation" de la mémoire interne du switch.
  def set_location(value)
    set_oid(OID_SYS_LOCATION, value, OctetString)
  end

  # Renvoie le modèle du switch
  def get_model
    case get_oid(OID_SYS_OBJECT_ID).to_str
    when OID_3COM_3300 then '3300'
    when OID_3COM_4200 then '4200'
    when OID_3COM_3800_A, OID_3COM_3800_B then '3800'
    when OID_CISCO_1130 then 'cisco_1130'
    when OID_HP_5412_ZL then 'hp_5412_zl'
    when OID_HP_2910_AL_24 then 'hp_2910_al_24'
    when OID_HP_2910_AL_48 then 'hp_2910_al_48'
    when OID_NETGEAR_GSM7224R then 'gsm7224r'
    when OID_NETGEAR_GSM7248R then 'gsm7248r'
    else raise "get_model: unknown switch model : #{get_oid(OID_SYS_OBJECT_ID)}"
    end
  end

  # Renvoie une description du switch
  def get_description
    get_oid(OID_SYS_DESCR)
  end

  # Renvoie l'uptime du switch en secondes.
  def get_uptime
    get_oid(OID_SYS_UPTIME).to_i / 100
  end


  #--
  # REBOOT & RESET
  #++
  # Reboote le switch
  def reboot
    set_oid(OID_RESET_CONTROL, 2, Integer)
  end

  # METHODE DANGEREUSE, à utiliser avec discernement.
  # Réinitialise le switch à ses valeurs de sortie d'usine.
  def factory_reset!
    #set_oid(OID_RESET_CONTROL, 3, Integer)
  end

  #--
  # MULTICAST
  #++
  # Teste si l'IGMP snooping (multicast) est activé sur le switch
  def multicast_enabled?
    #TODO: debug ici: renvoie Null -> disabled ?
    get_oid(OID_IGMP_SNOOP).to_i == 1
  end

  # Active l'IGMP snooping (multicast).
  def multicast_enable
    set_oid(OID_IGMP_SNOOP, 1, SNMP::Integer)
  end

  # Désactive l'IGMP snooping (multicast).
  def multicast_disable
    set_oid(OID_IGMP_SNOOP, 2, SNMP::Integer)
  end

  # Désactive le querymode pour le multicast.
  def querymode_disable
    set_oid(OID_IGMP_SNOOP_QUERY_MODE, 2, SNMP::Integer)
  end


  #--
  # METHODES PRIVEES
  #++
  #private


  # some useful common constants
  OID_3COM = '1.3.6.1.4.1.43'
  OID_3COM_3800_A  = '1.3.6.1.4.1.43.1.8.39'
  OID_3COM_3800_B  = '1.3.6.1.4.1.43.1.8.40'
  OID_3COM_3300    = '1.3.6.1.4.1.43.10.27.4.1.2.2'
  OID_3COM_4200    = '1.3.6.1.4.1.43.10.27.4.1.2.11'
  OID_HP_5412_ZL   = '1.3.6.1.4.1.11.2.3.7.11.51'
  OID_HP_2910_AL_24   = '1.3.6.1.4.1.11.2.3.7.11.86'
  OID_HP_2910_AL_48   = '1.3.6.1.4.1.11.2.3.7.11.87'
  OID_CISCO_1130 = '1.3.6.1.4.1.9.1.618'
  OID_NETGEAR_GSM7224R = '1.3.6.1.4.1.4526.100.11.1';
  OID_NETGEAR_GSM7248R = '1.3.6.1.4.1.4526.100.11.2';


  OID_SYSTEM = '1.3.6.1.2.1.1'
  OID_SYS_DESCR     = '1.3.6.1.2.1.1.1.0'
  OID_SYS_OBJECT_ID = '1.3.6.1.2.1.1.2.0'
  OID_SYS_UPTIME    = '1.3.6.1.2.1.1.3.0'
  OID_SYS_CONTACT   = '1.3.6.1.2.1.1.4.0'
  OID_SYS_NAME      = '1.3.6.1.2.1.1.5.0'
  OID_SYS_LOCATION  = '1.3.6.1.2.1.1.6.0'
  OID_IGMP_SNOOP            = '1.3.6.1.4.1.43.10.37.1.1.0'
  OID_IGMP_SNOOP_QUERY_MODE = '1.3.6.1.4.1.43.10.37.1.10.0'

  # Renvoie la valeur associée à un OID.
  def get_oid(oid)
    @manager.get(oid).varbind_list[0].value
  end

  # Définit la valeur associée à un OID.
  def set_oid(oid, value, type)
    #Lecture seule: on n'écrit rien pour l'instant!!!
    return nil
    varbind = VarBind.new(oid, type.new(value))
    response = @manager.set(varbind)
    raise "set_oid: error (#{response.error_status}) while trying to define OID #{oid}" if response.error_index != 0
    return true
  end

end
