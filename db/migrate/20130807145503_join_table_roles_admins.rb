class JoinTableRolesAdmins < ActiveRecord::Migration
  def change
    create_table :admins_roles do |t|
      t.belongs_to :role_id
      t.belongs_to :admin_id
    end
  end
end
