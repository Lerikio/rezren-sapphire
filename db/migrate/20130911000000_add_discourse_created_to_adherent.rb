class AddDiscourseCreatedToAdherent < ActiveRecord::Migration
  def change
    add_column :adherents, :discourse_created, :boolean, :default => false
  end
end
