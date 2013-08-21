# -*- encoding : utf-8 -*-
class CreateGenericDnsEntries < ActiveRecord::Migration
  def change
    create_table :generic_dns_entries do |t|

      t.string   :dns_type, null: false
      t.string   :name, null: false
      t.string   :return, null: false
      t.boolean  :external, default: false

      t.boolean  :archived, default: false
 
      t.timestamps
    end
  end
end
