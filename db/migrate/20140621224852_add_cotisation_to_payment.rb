class AddCotisationToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :cotisation, :Number
  end
end
