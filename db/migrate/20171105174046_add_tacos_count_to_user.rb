class AddTacosCountToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :tacos_count, :integer, default: 0
  end
end
