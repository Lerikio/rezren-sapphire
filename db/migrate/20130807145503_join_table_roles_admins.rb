class JoinTableRolesAdmins < ActiveRecord::Migration
  def change
    create_table :admins_roles do |t|
      t.belongs_to :role
      t.belongs_to :admin
    end
  end
end
