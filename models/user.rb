class User < ActiveRecord::Base
  has_many :tacos, primary_key: :slack_id, foreign_key: :recipient_id
  has_many :given_tacos, class_name: "Taco", primary_key: :slack_id, foreign_key: :giver_id
end
