# -*- encoding : utf-8 -*-
class CreateVlanConnections < ActiveRecord::Migration

# Table de jointure entre VLANs et Ports	
  def change
    create_table :vlan_connections do |t|
    	t.integer :port_id, null: false
    	t.integer :vlan, null: false
    	t.boolean :tagged, default: false

    	t.timestamps
    end
  end
end
