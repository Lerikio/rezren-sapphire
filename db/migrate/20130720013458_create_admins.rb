# -*- encoding : utf-8 -*-
class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|

      t.string     :password_hash, null: false
      t.string     :password_salt, null: false

      t.string     :username, null: false, index: true
      t.string     :display_name, null: false

      t.integer    :adherent_id

      t.boolean    :archived, default: false
      t.datetime   :last_login
      t.timestamps
    end
  end
end
