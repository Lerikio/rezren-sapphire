# -*- encoding : utf-8 -*-
class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|

      t.float    :value, default: 0
      t.float    :paid_value, default: 0

      t.string   :mean, null: false
      t.string   :bank_name

      t.text     :comment

      t.boolean  :archived, default: false
      t.string   :state
      t.datetime :cashed_date

      t.integer  :credit_id, null: false
      t.integer  :admin_id, null: false

      t.timestamps
    end
  end
end
