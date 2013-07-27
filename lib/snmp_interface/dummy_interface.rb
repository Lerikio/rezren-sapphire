class DummyInterface
  require 'highline/import'
  attr_reader :ip,:model

  # Indique si un vlan appartient à un port comme taggué ou untaggué.
  def is_on_vlan?(port_id, vlan_id)
      agree("is port #{port_id} on vlan #{vlan_id} ?")
  end

  # Indique si un vlan est taggué sur un port
  def is_on_tagged_vlan?(port_id, vlan_id)
    agree("is port #{port_id} on vlan #{vlan_id} tagged ?")
  end

  # Indique si un vlan est untaggué sur un port
  def is_on_untagged_vlan?(port_id, vlan_id)
    agree("is port #{port_id} on vlan #{vlan_id} untagged ?")
  end

  # Indique si un vlan est interdit sur un port
  def is_on_forbidden_vlan?(port_id, vlan_id)
    agree("is port #{port_id} on vlan #{vlan_id} forbidden ?")
  end

  # Indique si un vlan est ignoré sur un port
  def is_not_on_vlan?(port_id, vlan_id)
    agree("is port #{port_id} on vlan #{vlan_id} ignored ?")
  end

  # Renvoie l'état d'un vlan sur un port
  def get_vlan_state(port_id, vlan_id)
    ask("State of port #{port_id} on vlan #{vlan_id} (Tagged, Untagged, Forbidden) ?")
  end

  # Renvoit un _Array_ contenant les +vlan_id+ auxquels appartient un port.
  # Utilise la mise en cache décrite dans la documentation de la méthode _vlans_id_.
  def get_vlans(port_id)
    ask( "VLANs du port #{port_id}",
              lambda { |ans| ans =~ /^-?\d+$/ ? Integer(ans) : ans} ) do |q|
        q.gather = ""
      end
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
    say("Vlan #{vlan_id} forbidden on port #{port_id}")
  end

  # Ajoute un VLAN taggué à un port.
  def add_vlan_tagged(port_id, vlan_id)
    say("Vlan #{vlan_id} tagged on port #{port_id}")
  end

  # Ajoute un VLAN untaggué à un port.
  def add_vlan_untagged(port_id, vlan_id)
    say("Vlan #{vlan_id} untagged on port #{port_id}")
  end

  # Enlève un VLAN d'un port. (le met en état No)
  def del_vlan(port_id, vlan_id)
    say("Vlan #{vlan_id} removed from port #{port_id}")
  end

  # Si le vlan était marqué comme taggué ou untaggué pour le port 
  # en question sur l'OID adéquate, cette fonction supprime cet état.
  def del_vlan_tagged_or_untagged(port_id, vlan_id)
    say("Delete vlan #{vlan_id} tagged or untagged on port #{port_id}")
  end

  # Si le vlan était marqué comme interdit pour le port
  # en question sur l'OID adéquate, cette fonction supprime cet état.
  def del_vlan_forbidden(port_id, vlan_id)
    say("Delete vlan #{vlan_id} forbidden on port #{port_id}")
  end

  # Si le vlan était marqué comme untaggué pour le port 
  # en question sur l'OID adéquate, cette fonction supprime cet état.
  def del_vlan_untagged(port_id, vlan_id)
    say("Delete vlan #{vlan_id} untagged on port #{port_id}")
  end

  def vlans_ids
    ask( "VLANs utilises ?",
              lambda { |ans| ans =~ /^-?\d+$/ ? Integer(ans) : ans} ) do |q|
        q.gather = ""
      end
  end
end
