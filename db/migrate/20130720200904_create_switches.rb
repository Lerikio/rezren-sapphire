# -*- encoding : utf-8 -*-
class CreateSwitches < ActiveRecord::Migration
  def change
    create_table :switches do |t|
      t.string    :community, null: false
      t.string    :ip_admin, null: false
      t.boolean   :archived, default: false
      t.string    :description

      t.timestamps
    end
  end
end
