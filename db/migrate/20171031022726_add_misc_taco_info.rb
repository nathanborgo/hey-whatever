class AddMiscTacoInfo < ActiveRecord::Migration[5.1]
  def change
    change_table :tacos do |t|
      t.string :message_id
      t.float :given_at
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
