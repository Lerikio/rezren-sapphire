# -*- encoding : utf-8 -*-
class CreateMailings < ActiveRecord::Migration
  def change
    create_table :mailings do |t|
      t.string   :name, null: false
      t.text     :emails, null: false
      t.integer  :adherent_id, index: true
      t.boolean  :system, default: false

      t.boolean  :archived, default: false

      t.timestamps
    end
  end
end
