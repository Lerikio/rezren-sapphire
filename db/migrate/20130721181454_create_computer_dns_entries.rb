# -*- encoding : utf-8 -*-
class CreateComputerDnsEntries < ActiveRecord::Migration
  def change
    create_table :computer_dns_entries do |t|

      t.string   :name, null: false
      t.integer  :computer_id, null: false

      t.boolean  :archived, default: false

      t.timestamps
    end
  end
end
