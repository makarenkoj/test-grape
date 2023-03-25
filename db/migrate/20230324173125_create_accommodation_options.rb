class CreateAccommodationOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :accommodation_options do |t|
      t.references :accommodation, null: false, foreign_key: true
      t.references :option, null: false, foreign_key: true

      t.timestamps
    end
  end
end
