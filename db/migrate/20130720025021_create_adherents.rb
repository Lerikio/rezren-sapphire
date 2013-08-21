# -*- encoding : utf-8 -*-
class CreateAdherents < ActiveRecord::Migration
  def change
	create_table :adherents do |t|
		
		t.string   :first_name, null: false
		t.string   :last_name, null: false

		t.string   :username
		t.string   :email, null: false
		t.string   :state, default: "created"
		t.integer  :promotion
		t.boolean  :rezoman, default: false
		t.boolean  :resident, default: false
		t.boolean  :supelec, default: false
		t.boolean  :archived, default: false

		t.string   :password_salt
		t.string   :password_hash

		t.timestamps
	end
	add_index :adherents, [:first_name, :last_name]

  end
end
