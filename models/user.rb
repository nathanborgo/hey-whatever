class User < ActiveRecord::Base
  has_many :tacos, primary_key: :slack_id, foreign_key: :recipient_id
end
