class AddModelToSwitch < ActiveRecord::Migration
  def change
    add_column :switches, :model, :string
  end
end
