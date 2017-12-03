class Message < ActiveRecord::Base
  has_many :tacos
  belongs_to :channel
  belongs_to :user
end

