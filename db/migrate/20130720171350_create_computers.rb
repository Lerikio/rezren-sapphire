# -*- encoding : utf-8 -*-
class CreateComputers < ActiveRecord::Migration
  def change
    create_table :computers do |t|
      t.string    :mac_address, null: false, index: true
      t.integer   :adherent_id, index: true
      t.string    :ip_address, null: false
      t.boolean   :archived, default: false

      t.timestamps
    end
  end
end
