#encoding: utf-8
#-------
#       Copyright 2012
#
#       This file is part of Kettu-admin.
#
#       Kettu-admin is free software: you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation, either version 3 of the License, or
#       (at your option) any later version.
#
#       Kettu-admin is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with Kettu-admin.  If not, see <http://www.gnu.org/licenses/>.
#
#       By Clément Parisot <clement.parisot@gmail.com> 
#       Adapted from Sébastien Hocquet's code 
#-------
# Gestion générique des switchs par SNMP.
# Comprend la gestion des ports, des vlans (en lecture seule ici) et des macs
# vues sur chaque port.
#
# la méthode load_ports_and_vlans est spécifique à chaque modèle 
# et donc à redéfinir dans une classe fille
#
# Commentaires et explications originales par Sébastien Hocquet
#-------

class SwitchInterface < SnmpInterface
  require 'snmp'
  include SNMP

  attr_reader :ip, :model

  #--
  # INFOS SUR LES PORTS
  #++

  # Renvoit un Hash dont les clés sont les identifiants des ports dans la représentation
  # interne du switch (+port_id+), et les valeurs sont du type 
  # <tt>{:unit => 1, :num => 23}</tt>:
  #      <tt>:unit</tt> est le numéro de switch dans son switch
  #      <tt>:num</tt> le numéro "classique" du port sur ce switch
  #
  # Exemple de résultat : <tt>{101 => {:unit => 1, :num => 1},
  # 102 => {:unit => 1, :num => 2},
  # 201 => {:unit => 2, :num => 1},
  # 202 => {:unit => 2, :num => 2}}</tt>
  #

  def ports(force_reload=false)
    load_ports_and_vlans if force_reload or !@ports
    return @ports
  end

  def ports_size
    #le numéro du dernier port
    ports.sort.last[0]
  end

  # Indique si un port est activé (des paquets peuvent y transiter)
  def enabled?(port_id)
    state = get_oid(OID_IF_ADMIN_STATUS + "." + port_id.to_s).to_i
    raise "enabled?: unknown port_id (#{port_id})" if state == SNMP::Null
    case state
    when 1 then true
    when 2, 3 then false # 3 for "testing" (no packet can pass in the testing mode).
    else raise "enabled?: unknown state (#{state})"
    end
  end

  # Active un port.
  def enable(port_id)
    set_oid(OID_IF_ADMIN_STATUS + "." + port_id.to_s, 1, SNMP::Integer)
  end

  # Désactive un port.
  def disable(port_id)
    set_oid(OID_IF_ADMIN_STATUS + "." + port_id.to_s, 2, SNMP::Integer)
  end

  # Indique si la connexion à un port est actuellement utilisée 
  # i.e. si le port aboutit à une carte réseau allumée
  def link_up?(port_id)
    state = get_oid(OID_IF_OPER_STATUS + "." + port_id.to_s).to_i
    raise "link_up?: unknown port_id (#{port_id})" if state == SNMP::Null
    case state
    when 1 then true
    else false
    end
  end

  #--
  # GESTIONS DES VLANS
  #++

  def vlans(force_reload=false)
    load_ports_and_vlans if force_reload or !@vlans
    return @vlans
  end

  # Renvoie un _Array_ contenant l'ensemble des identifiants internes (+vlan_id+) 
  # des VLAN définis sur ce switch.
  def vlans_ids(force_reload=false)
    load_ports_and_vlans if force_reload or !@vlans_ids
    return @vlans_ids
  end


  #--
  # SURVEILLANCE DES MACS
  #++

  # Renvoie le port associé à un bridge.
  #
  # Le résultat est mis en cache: 
  #        -soit lors de l'instanciation de l'objet si
  # l'option +bridges+ a été fournie (et, dans ce cas, aucune vérification
  # de l'exactitude de la valeur de l'option n'est effectuée),
  #        -soit au moment du premier appel de l'une des 
  # méthodes suivantes : _bridges_, _port_of_bridge_, _macs_ ou _print_macs_.
  #
  # Mettez l'argument +force_reload+ à +true+ pour supprimer le cache
  # et (re)calculer le résultat.
  #

  def port_of_bridge(bridge, force_reload=false)
    h = bridges(force_reload)
    raise "port_of_bridge: unknown bridge (#{bridge})" if (h[bridge].nil?)
    return h[bridge]
  end

  # Renvoie un _Hash_ associant à chaque bridge du stack l'identifiant 
  # du port correspondant.
  #
  # Le résultat est mis en cache :
  #        -soit lors de l'instanciation de l'objet si l'option +bridges+
  # a été fournie (et, dans ce cas, aucune vérification de l'exactitude 
  # de la valeur de l'option n'est effectuée)
  #        -soit au moment du premier appel de l'une des méthodes 
  # suivantes : _bridges_, _port_of_bridge_ ou _macs_.
  #
  # Mettez l'argument +force_reload+ à +true+ pour supprimer
  # le cache et (re)calculer le résultat.

  def bridges(force_reload=false)
    load_bridges if force_reload or !@bridges
    return @bridges
  end

  # Renvoit un _Hash_ dont chaque clé est un +port_id+ et la valeur associée le tableau
  # des "dernières" adresses MACs (en majuscules) vues par ce port.
  # Utilise la mise en cache décrite dans la documentation de la méthode _bridges_.
  #
  # Exemple de résultat :
  # <tt>{14 => ["00:0A:04:B8:72:21"],
  # 18 => ["00:0B:AC:2C:F7:40", "00:0F:B0:6A:C6:30", "00:14:38:08:39:34"]}</tt>
  def macs
    # Pour les 3300, il faut réinstancier le manager en changeant la chaîne
    # Community : elle doit inclure le VLAN que l'on souhaite monitorer (2).
    # TODO: mettre cette vérification dans une classe fille ! 
    if model == "3300"
      @manager = Manager.new(:Version => :SNMPv1, :Host => @ip, :Port => 161, :Community => "private@2")
    end

    load_bridges
    hash = Hash.new
    @manager.walk([OID_MACS_BRIDGE, OID_MACS_ADDRESS]) do |bridge, address|
      bridge_id=bridge.value.to_i
      port_id = port_of_bridge(bridge_id) if bridge_id !=0
      addr_hexa = address.value.unpack('C*')
      addr = sprintf('%02X:%02X:%02X:%02X:%02X:%02X', addr_hexa[0], addr_hexa[1], addr_hexa[2], addr_hexa[3], addr_hexa[4], addr_hexa[5])
      hash[port_id] = [] if hash[port_id].nil?
      hash[port_id] << addr
    end
    return hash
  end


  #--
  # FONCTIONS UTILES POUR L'UTILISATION EN LIGNE DE COMMANDE
  #++
  # Affiche la liste des VLANS sur la sortie standard (cf. méthode _vlans_).
  def print_vlans(force_reload=false)
    vlans(force_reload).sort do |a, b|
      if a[1][:tag] and b[1][:tag] and a[1][:tag] != b[1][:tag]
        a[1][:tag].to_s <=> b[1][:tag]
      else
        a[1][:num] <=> b[1][:num]
      end
    end.each do |vlan_id, vlan|
      puts "VLAN #{vlan[:num]} " +
        if vlan[:tag].nil? then "(tag inconnu)" elsif vlan[:tag] then "(tagguée)    " else "(non-taguée) " end +
        " : #{vlan_id}"
    end
    return nil
  end

  # Affiche la liste des VLANS auxquels appartient un port sur la sortie standard 
  # (cf. méthode _get_vlans_)
  # L'indication entre crochets concerne le tag.
  def print_get_vlans(port_id, force_reload=false)
    load_ports_and_vlans if force_reload
    string = get_vlans(port_id).sort do |a, b|
      if vlans[a][:tag] and vlans[b][:tag] and vlans[a][:tag] != vlans[b][:tag]
        vlans[a][:tag].to_s <=> vlans[b][:tag].to_s
      else
        vlans[a][:num] <=> vlans[b][:num]
      end
    end.collect do |id|
      vlans[id][:num].to_s +
        if vlans[id][:tag].nil? then "[?]" elsif vlans[id][:tag] then "[T]" else "[U]" end +
        " (id #{id})"
    end.join(", ")
    print string
    return nil
  end

  # Affiche la liste des ports connus par le switch ainsi qu'un résumé 
  # de leur état sur la sortie standard (cf. méthode _ports_).
  def print_ports(force_reload=false)
    ports(force_reload).sort do |a, b|
      if a[1][:unit] != b[1][:unit]
        a[1][:unit] <=> b[1][:unit]
      else
        a[1][:num] <=> b[1][:num]
      end
    end.each do |port_id, port|
      print "PORT #{port_id} (unit #{port[:unit]}, num #{port[:num]}) : " +
        if enabled?(port_id) then "[enabled]" else "[DISABLED]" end + " " +
        if link_up?(port_id) then "[up]" else "[down]" end + " - VLANS : "
        print_get_vlans(port_id, force_reload)
        print "\n"
    end
    return nil
  end

  # Affiche sur la sortie standard un rapport des "dernières" 
  # adresses MACs vues par les ports du switch
  # (cf. méthode _macs_).
  def print_macs(force_reload=false)
    load_bridges if force_reload
    macs.each do |port_id, macs|
      puts "PORT #{port_id} : " + macs.sort.join(", ")
    end
    return nil
  end

  #--
  # METHODES PRIVEES
  #++
  #private

  OID_INTERFACES = '1.3.6.1.2.1.2'
  OID_IF_INDEX        = '1.3.6.1.2.1.2.2.1.1'
  OID_IF_DESCR        = '1.3.6.1.2.1.2.2.1.2'
  OID_IF_ADMIN_STATUS = '1.3.6.1.2.1.2.2.1.7'
  OID_IF_OPER_STATUS  = '1.3.6.1.2.1.2.2.1.8'
  OID_IF_NAMES        = '1.3.6.1.2.1.31.1.1.1.1'
  OID_BRIDGE = '1.3.6.1.2.1.17'
  OID_PORT_OF_BRIDGE = '1.3.6.1.2.1.17.1.4.1.2'
  OID_MACS_ADDRESS   = '1.3.6.1.2.1.17.4.3.1.1'
  OID_MACS_BRIDGE    = '1.3.6.1.2.1.17.4.3.1.2'
  OID_INTERFACES_EXTENSIONS = '1.3.6.1.2.1.31'
  OID_VLAN_CONTROL = '1.3.6.1.2.1.31.1.2.1.3'
  OID_MANAGED_OBJECTS_FOR_BRIDGES = '1.3.6.1.2.1.16'
  OID_RESET_CONTROL = '1.3.6.1.2.1.16.19.5.0'
  OID_3COM = '1.3.6.1.4.1.43'
  OID_IGMP_SNOOP            = '1.3.6.1.4.1.43.10.37.1.1.0'
  OID_IGMP_SNOOP_QUERY_MODE = '1.3.6.1.4.1.43.10.37.1.10.0'


  # Cette méthode est appelée lors du premier appel à vlans, vlans_ids (si le paramètre
  # +vlans_ids+ n'a pas été passé lors de l'initialisation de lobjet) ou ports.
  # Son exécution est probablement l'opération la plus longue 
  # au cours de d'une utilisation de la classe (parcourt d'un grand nombre 
  # d'OIDs nécessaire).
  # Cette méthode est appelée lors du premier appel de la méthode bridges.
  # C'est également assez long.
  def load_bridges(options = {})
    options[:debug] ||= false
    @bridges = Hash.new
    @manager.walk(OID_PORT_OF_BRIDGE) do |port_of_bridge|
      port_of_bridge ifDescr if (options[:debug])
      bridge = port_of_bridge.name.to_s.split('.').last.to_i
      port_id = port_of_bridge.value.to_i
      @bridges[bridge] = port_id
    end
    return true
  end

  #redéfini dans les classes filles
  def load_port_and_vlans(options={})
    return nil
  end

end

