class Taco < ActiveRecord::Base
  belongs_to :user, primary_key: :slack_id, foreign_key: :recipient_id, counter_cache: true

  validates :giver_id, presence: true
  validates :recipient_id, presence: true
  validates :channel_id, presence: true
  validates :message_id, presence: true
  validates :given_at, presence: true

  validate :users_cannot_give_to_themselves
  validate :users_cannot_give_more_than_five

  before_validation :set_created_at, on: :create
  before_validation :set_updated_at, on: :update

  private

  def self.created_today
    where("created_at >= ?", Date.today.to_time)
  end

  def users_cannot_give_to_themselves
    return if !giver_id || !recipient_id

    if giver_id == recipient_id
      errors.add(:base, "You can't give yourself tacos.")
    end
  end

  def users_cannot_give_more_than_five
    if Taco.where(giver_id: giver_id).created_today.count >= 5
      errors.add(:base, "You can't give more than 5 tacos per day.")
    end
  end

  def set_created_at
    self.created_at = DateTime.now
  end

  def set_updated_at
    self.updated_at = DateTime.now
  end
end
