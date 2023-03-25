class CreateAccommodations < ActiveRecord::Migration[7.0]
  def change
    create_table :accommodations do |t|
      t.string :title, null: false, default: ''
      t.string :type, null: false
      t.references :city, null: false, foreign_key: true
      t.string :phone_number, null: false
      t.string :address, null: false
      t.integer :price, null: false

      t.timestamps
    end
  end
end
