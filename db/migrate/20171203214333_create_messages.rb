class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.integer :user_id
      t.integer :channel_id
      t.float :ts
      t.text :text

      t.timestamps
    end

    remove_column :tacos, :original_text, :string
    remove_column :tacos, :channel_id, :string
    remove_column :tacos, :given_at, :float

    remove_column :tacos, :message_id, :string
    add_column :tacos, :message_id, :integer
  end
end
