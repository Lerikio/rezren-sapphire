# -*- encoding : utf-8 -*-
class CreateVlans < ActiveRecord::Migration
  def change
    create_table :vlans do |t|
      t.integer  :number
      t.string   :name
      t.boolean  :archived, default: false


      t.timestamps
    end
  end
end
