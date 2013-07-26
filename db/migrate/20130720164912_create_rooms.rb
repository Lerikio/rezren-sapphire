# -*- encoding : utf-8 -*-
class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string      :building, null: false, limit: 1
      t.string      :number, null: false
      t.integer     :adherent_id, default: nil, index: true
      t.integer     :port_id, index: true
      t.boolean     :archived, default: false

      t.timestamps
    end
    add_index :rooms, [:number, :building]
  end
end
