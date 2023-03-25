class CreateUserTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :user_tokens, id: :uuid do |t|
      t.string :token, null: false, default: ''
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :user_tokens, :token
  end
end
