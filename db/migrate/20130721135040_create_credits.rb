# -*- encoding : utf-8 -*-
class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.float    :value, default: 0
      t.date     :next_debit, default: Time.now
      t.boolean  :archived, default: false
      t.integer  :adherent_id, null: false, index: true

      t.timestamps
    end
  end
end
