class CreateTacos < ActiveRecord::Migration[5.1]
  def change
    create_table :tacos do |t|
      t.string :giver_id
      t.string :recipient_id
      t.string :original_text
      t.string :channel_id
    end
  end
end
