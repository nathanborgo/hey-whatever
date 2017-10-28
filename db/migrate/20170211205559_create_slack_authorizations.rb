class CreateSlackAuthorizations < ActiveRecord::Migration[5.0]
  def change
    create_table :slack_authorizations do |t|
      t.string :team_id
      t.string :team_name
      t.string :user_id
      t.string :user_access_token
      t.string :bot_id
      t.string :bot_access_token
  	end
  end
end
