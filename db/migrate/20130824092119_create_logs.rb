class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.string :source
      t.string :status
      t.text :content

      t.timestamps
    end
  end
end
