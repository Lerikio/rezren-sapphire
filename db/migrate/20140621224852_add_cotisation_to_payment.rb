class AddCotisationToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :cotisation, :float
  end
end
