class NetgearInterface < SwitchInterface
  require 'snmp'
  include SNMP

  attr_reader :ip,:model

  # Arrive maintenant la partie compliquée : une petite explication s'impose.
  # Je pars du principe que vous savez ce qu'est une OID (ie voir les suites 
  # de chiffre en bas de ce fichier)
  #
  # On utilise ici 3 OIDs : 
  # une qui nous sert à savoir sur quels ports un vlan est untaggué ou taggué.
  # une qui nous sert à savoir sur quels ports un vlan est forbidden
  # une qui nous sert à savoir sur quels ports un vlan est untaggué.
  #
  # il y a en fait 3 racines d'OID, puis autant de fille à cette racine 
  # que de vlan. Cette racine est par exmeple pour le premier :
  # '1.3.6.1.2.1.17.7.1.4.3.1.2', pour avoir les infos sur le vlan 1, 
  # on rajoute .1 à la fin ce qui donne'1.3.6.1.2.1.17.7.1.4.3.1.2.1'. 
  # Pour avoir les infos sur le vlan 3, on rajoute .3 à la fin, ce qui 
  # donne '1.3.6.1.2.1.17.7.1.4.3.1.2.3'.
  #
  #
  #
  # Ces OID quand on les appelle nous fournissent 1 information sous 
  # forme de paquets d'octets.
  # par exemple é/000/244/344/377/377/.../377/"
  #
  # Il y a 3 trucs à savoirs : 
  # Chaque nombre à 3 chiffre est en base huit entre 0 377 soit 0 et 255 en base 10
  # Si on les transcrit en binaire, ca donne des chiffre entre 00000000 et 11111111,
  # c'est à dire un paramètre à 0 ou 1 pour 8 ports
  # Il y a beaucoup plus d'information que nécessaire : on a besoin des N premiers
  # bits, où N est le plus grand numéro de port sur ce switch
  #
  # On a donc besoin de transcrire des nombres octets en binaire et inversement 
  # pour lire et éditer des paramètres vlan du switchs.
  #
  # Enfin pour bien comprendre
  # La première OID sur le vlan 1 vous dira par exmeple en binaire : 11000111 
  # ce qui signifie que le vlan 1, sur les 2 premiers et 3 derniers ports, est 
  # taggué ou untaggué
  # 
  # Ensuite la 2e nous dira 00110000 soit: le vlan 1 sur les ports 3 et 4 est forbidden.
  # Enfin La dernière nous dit 00000111 donc le vlan1 sur les 3 derniers 
  # ports est untaggué
  #
  # On en déduis que le vlan 1 est 
  # (1) T (2) T (3) F (4) F (5) N (6) U (7) U (8) U
  #
  # Donc pour ce switch avec 26 ports, au format conventionnel, on aura pour le 
  # vlan2 pour les 3 OID:
  # 11111111111111111111111111 (untaggué ou taggué partout)
  # 00000000000000000000000000 (forbid nulle part)
  # 11111111111111111111111100 (taggué uniquement sur les 2 derniers,
  #                             untaggué partout ailleurs)
  # 
  #

  # Indique si un vlan appartient à un port comme taggué ou untaggué.
  def is_on_vlan?(port_id, vlan_id)
    return get_tagged_or_untagged_ports_binary(vlan_id)[port_id-1,1].to_i == 1
  end

  # Indique si un vlan est taggué sur un port
  def is_on_tagged_vlan?(port_id, vlan_id)
    return ((is_on_vlan?(port_id,vlan_id)) and !(is_on_untagged_vlan?(port_id,vlan_id)))
  end

  # Indique si un vlan est untaggué sur un port
  def is_on_untagged_vlan?(port_id, vlan_id)
    return get_untagged_ports_binary(vlan_id)[port_id-1,1].to_i == 1
  end

  # Indique si un vlan est interdit sur un port
  def is_on_forbidden_vlan?(port_id, vlan_id)
    return get_forbidden_ports_binary(vlan_id)[port_id-1,1].to_i == 1
  end

  # Indique si un vlan est ignoré sur un port
  def is_not_on_vlan?(port_id, vlan_id)
    return (!(is_on_vlan?(port_id,vlan_id)) and !(is_on_forbidden_vlan?(port_id,vlan_id)))
  end

  # Renvoie l'état d'un vlan sur un port
  def get_vlan_state(port_id, vlan_id)
    if is_on_tagged_vlan?(port_id, vlan_id)
      return "Tagged"
    elsif is_on_untagged_vlan?(port_id,vlan_id)
      return "Untagged"
    elsif is_on_forbidden_vlan?(port_id,vlan_id)
      return "Forbidden"
    else return "No"
    end
  end

  # Renvoit un _Array_ contenant les +vlan_id+ auxquels appartient un port.
  # Utilise la mise en cache décrite dans la documentation de la méthode _vlans_id_.
  def get_vlans(port_id)
    r = []
    for vlan_id in vlans_ids 
      if is_on_vlan?(port_id, vlan_id)
        r << vlan_id
      end
    end
    return r
  end

  # Renvoie une chaine de binaire de la taille du nombre du ports du switch, 
  # décodant une chaine d'octets
  def decode_octet_string(octet_string,nb_ports)
    # On veut savoir ici de combien d'octets de la chaîne on aura besoin : 
    # 26 ports c'est 4 octets minimum
    nb_octets = nb_ports/8+1
    # On renvoie ici le décodage de la chaine d'octet. 
    # Attention, la méthode unpack inverse tel un miroir les paquets de 8 bits obtenus.
    # Hors le switch ne le fait pas lui. Il faut donc les réinverser.
    o = octet_string.unpack("b"+(nb_octets*8).to_s)[0]
    so = ""
    for i in (0..nb_octets-1).to_a
      # Pour chaque Octet décodé, on inverse la chaîne de 8 bits, et on la 
      # rajoute à une chaîne so
      so = so+o[i*8,8].reverse
    end
    # On renvoie la chaîne tronquée au nombre de ports.
    return so[0,nb_ports]
  end


  # Renvoie une chaine d'octets décodant une chaîne binaire. 
  #
  # On a par exemple 26 bits, mais il faut renvoyer au switch un nombre d'octet
  # bien précis, supérieur à 4 octets. On va donc compléter les 26 bits avec 
  # tous les autres bits inutiles qu'il nous avait fournit lorsqu'on avait décodé
  # la chaîne de caractère la première fois.
  def encode_octet_string(binary_string, oos) # oos pour original octet ctring
    #Ici on rajoute les bits inutiles à la chaîne binaire en s'arrêtant 
    #dès qu'on atteint un nombre de bit divisible par 8.
    if (binary_string.size%8 != 0)
      i = (binary_string.size/8 + 1)*8-binary_string.size
      obs = decode_octet_string(oos, oos.size*8)
      binary_string = binary_string + obs[binary_string.size, i]
    end
    nb_octets = binary_string.size/8
    # On crée un nouvel Octet String
    osn = SNMP::OctetString.new
    # Pour chaque paquet de 8 bits, on va les mettre en octet, et les insérer
    # dans l'octet string solution.
    for i in (0..nb_octets-1).to_a
      octet = binary_string[i*8,8].to_i(2).to_s(8)

      # Ligne inutile, je pense, à vérifier.
      octet = "0" + octet while octet.size < 3 if octet.size < 3 
      osn << octet.to_i(8)

    end
    # Renvoie la solution plus le reste des bits inutiles qu'on avait
    # pas mis dans binary string.
    return osn + oos[nb_octets..oos.size-1]
  end

  # Renvoie un OctetString donnant les ports où le vlan est untaggué ou taggué
  def get_tagged_or_untagged_ports(vlan_id)
    return get_oid(OID_VLAN_STATIC_EGRESS_PORTS + '.' + vlan_id.to_s);
  end

  # Renvoie un OctetString donnant les ports où le vlan est interdit
  def get_forbidden_ports(vlan_id)
    return get_oid(OID_VLAN_FORBIDDEN_EGRESS_PORTS + '.' + vlan_id.to_s);
  end

  # Renvoie un OctetString donnant les ports où le vlan est untaggué
  def get_untagged_ports(vlan_id)
    return get_oid(OID_VLAN_STATIC_UNTAG_PORTS + '.' + vlan_id.to_s);
  end


  # Renvoie un nombre binaire donnant les ports où le vlan est untaggué ou taggué
  def get_tagged_or_untagged_ports_binary(vlan_id)
    return decode_octet_string(get_tagged_or_untagged_ports(vlan_id),ports_size);
  end

  # Renvoie un nombre binaire donnant les ports où le vlan est interdit
  def get_forbidden_ports_binary(vlan_id)
    return decode_octet_string(get_forbidden_ports(vlan_id),ports_size);
  end

  # Renvoie un nombre binaire donnant les ports où le vlan est untaggué
  def get_untagged_ports_binary(vlan_id)
    return decode_octet_string(get_untagged_ports(vlan_id),ports_size);
  end

  # Ajoute un VLAN interdit à un port.
  def add_vlan_forbidden(port_id, vlan_id)
    del_vlan(port_id, vlan_id)
    portsf  = get_forbidden_ports_binary(vlan_id)
    portsf[port_id-1,1] = "1"
    set_oid(OID_VLAN_FORBIDDEN_EGRESS_PORTS + '.' + vlan_id.to_s, encode_octet_string(portsf,get_forbidden_ports(vlan_id)), SNMP::OctetString)
  end

  # Ajoute un VLAN taggué à un port.
  def add_vlan_tagged(port_id, vlan_id)
    del_vlan_forbidden(port_id, vlan_id)
    del_vlan_untagged(port_id, vlan_id)
    portstu  = get_tagged_or_untagged_ports_binary(vlan_id)
    puts portstu
    if portstu[port_id-1,1]!= "1"
      portstu[port_id-1,1] = "1"
      set_oid(OID_VLAN_STATIC_EGRESS_PORTS + '.' + vlan_id.to_s, encode_octet_string(portstu,get_tagged_or_untagged_ports(vlan_id)), SNMP::OctetString)
    end
  end

  # Ajoute un VLAN untaggué à un port.
  def add_vlan_untagged(port_id, vlan_id)
    del_vlan_forbidden(port_id,vlan_id)
    add_vlan_tagged(port_id,vlan_id)
    portsu  = get_untagged_ports_binary(vlan_id)
    portsu[port_id-1,1] = "1"
    set_oid(OID_VLAN_STATIC_UNTAG_PORTS+ '.' +vlan_id.to_s, encode_octet_string(portsu,get_untagged_ports(vlan_id)), SNMP::OctetString)
  end

  # Enlève un VLAN d'un port. (le met en état No)
  def del_vlan(port_id, vlan_id)
    del_vlan_untagged(port_id, vlan_id)
    del_vlan_tagged_or_untagged(port_id, vlan_id)
    del_vlan_forbidden(port_id, vlan_id)
  end

  # Si le vlan était marqué comme taggué ou untaggué pour le port 
  # en question sur l'OID adéquate, cette fonction supprime cet état.
  def del_vlan_tagged_or_untagged(port_id, vlan_id)
    portstu = get_tagged_or_untagged_ports_binary(vlan_id)
    if portstu[port_id-1,1]!= "0"
      portstu[port_id-1,1]  = "0"
      set_oid(OID_VLAN_STATIC_EGRESS_PORTS + '.'  + vlan_id.to_s, encode_octet_string(portstu,get_tagged_or_untagged_ports(vlan_id)), SNMP::OctetString)
    end
  end

  # Si le vlan était marqué comme interdit pour le port
  # en question sur l'OID adéquate, cette fonction supprime cet état.
  def del_vlan_forbidden(port_id, vlan_id)
    portsf  = get_forbidden_ports_binary(vlan_id)
    if portsf[port_id-1,1]!= "0" 
      portsf[port_id-1,1]  = "0"
      set_oid(OID_VLAN_FORBIDDEN_EGRESS_PORTS + '.' + vlan_id.to_s, encode_octet_string(portsf,get_forbidden_ports(vlan_id)), SNMP::OctetString)
    end
  end

  # Si le vlan était marqué comme untaggué pour le port 
  # en question sur l'OID adéquate, cette fonction supprime cet état.
  def del_vlan_untagged(port_id, vlan_id)
    portsu  = get_untagged_ports_binary(vlan_id)
    if portsu[port_id-1,1]!= "0"
      portsu[port_id-1,1]  = "0"
      set_oid(OID_VLAN_STATIC_UNTAG_PORTS + '.' + vlan_id.to_s, encode_octet_string(portsu,get_untagged_ports(vlan_id)), SNMP::OctetString)
    end
  end

  #Ajout d'une adresse MAC autorisée sur un VLAN sur un port
  def add_mac(port_id, vlan_id, mac_address)
    set_oid(OID_NG_PORTSECURITY + '.8.' + port_id.to_s, vlan_id.to_s + ' ' + mac_address, SNMP::OctetString)
  end

  #Suppression d'une adresse MAC autorisée sur un VLAN sur un port
  def del_mac(port_id, vlan_id, mac_address)
    set_oid(OID_NG_PORTSECURITY + '.9.' + port_id.to_s, vlan_id.to_s + ' ' + mac_address, SNMP::OctetString)
  end

  #Récupération de la liste des addresses MAC autorisées sur un VLAN sur un port
  def list_macs(port_id)
    get_oid(OID_NG_PORTSECURITY + '.6.' + port_id.to_s)
  end

  def flush_macs(port_id)
    macs = list_macs(port_id).split(',')
    macs.each do |mac|
      tab = mac.split("\s")
      vlan_id = tab[0]
      mac_address = tab[1]
      del_mac(port_id, vlan_id, mac_address)
    end
  end

  #Renvoie 1 si PortSecurity est actif, 2 sinon 
  def get_port_security_status(port_id)
    get_oid(OID_NG_PORTSECURITY + '.1.' + port_id.to_s)
  end

  #1 pour activer PortSecurity, 2 sinon
  def set_port_security_status(port_id, status)
    set_oid(OID_NG_PORTSECURITY + '.1.' + port_id.to_s, status, SNMP::Integer)
  end

  #private

  OID_BRIDGE = '1.3.6.1.2.1.17'
  OID_PORT_OF_BRIDGE = '1.3.6.1.2.1.17.1.4.1.2'
  OID_MACS_ADDRESS   = '1.3.6.1.2.1.17.4.3.1.1'
  OID_MACS_BRIDGE    = '1.3.6.1.2.1.17.4.3.1.2'
  OID_VLAN_STATIC_EGRESS_PORTS    = '1.3.6.1.2.1.17.7.1.4.3.1.2'
  OID_VLAN_FORBIDDEN_EGRESS_PORTS = '1.3.6.1.2.1.17.7.1.4.3.1.3'
  OID_VLAN_STATIC_UNTAG_PORTS     = '1.3.6.1.2.1.17.7.1.4.3.1.4'
  OID_NG_PORTSECURITY = '1.3.6.1.4.1.4526.10.20.1.2.1'

  def load_ports_and_vlans(options = {})
    options[:debug] ||= false
    @ports = Hash.new
    @vlans = Hash.new
    @vlans_ids = []
    @manager.walk(OID_IF_NAMES) do |ifName|
      puts ifName if (options[:debug])
      name_value = ifName.value.to_s

      # if name_value.include?("DEFAULT_VLAN")
      #   vlan_num = 1
      #   @vlans[vlan_num] = {:name => "VLAN1"}
      # elsif name_value.include?("VLAN10") #cas part. pour le masterswitch
      #   vlan_num = 10
      #   @vlans[vlan_num] = {:name => "VLAN10"}
      # elsif name_value.include?("VLAN")
      #   vlan_num = ifName.value.to_str[-1].to_i
      #   @vlans[vlan_num] = {:name => name_value}
      if !(name_value.include?("lo")) 
        port_id = ifName.name.to_s.split('.').last.to_i
        @ports[port_id] = {:name => name_value}
      end
    end
    @vlans_ids = [1,2,3,4,5,6,7]
    @vlans_ids.each do |vlan_id|
      @vlans[vlan_id] = {:name => "VLAN"+vlan_id.to_s, :num => vlan_id}
    end
    return true
  end

end
