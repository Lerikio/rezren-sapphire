# -*- encoding : utf-8 -*-
class CreateConnexions < ActiveRecord::Migration

# Table de jointure entre VLANs et Ports	
  def change
    create_table :connexions do |t|
    	t.belongs_to :vlan
    	t.belongs_to :port
    	t.boolean :tagged, default: false

    	t.timestamps
    end
  end
end
