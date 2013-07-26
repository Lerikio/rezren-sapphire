# -*- encoding : utf-8 -*-
class CreatePorts < ActiveRecord::Migration
  def change
    create_table :ports do |t|
      t.integer :number
      t.integer :switch_id, null: false, index: true
      t.boolean :archived, default: false


      t.timestamps
    end
  end
end
