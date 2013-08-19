# -*- encoding : utf-8 -*-
class CreateAdherents < ActiveRecord::Migration
  def change
	create_table :adherents do |t|
		
		t.string   :full_name, null: false, index: true
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
  end
end
