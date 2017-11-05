class Taco < ActiveRecord::Base
  validate :users_cannot_give_to_themselves
  validate :users_cannot_give_more_than_five

  after_create :create_user

  before_validation :set_created_at, on: :create
  before_validation :set_updated_at, on: :update

  private

  def self.created_today
    where("created_at >= ?", Date.today.to_time)
  end

  def users_cannot_give_to_themselves
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

  def create_user
    response = Faraday.new(url: 'https://slack.com').get("/api/users.info?token=#{ENV['SLACK_BOT_ACCESS_TOKEN']}&user=#{recipient_id}")
    name = JSON.parse(response.body).dig("user", "profile", "real_name")
    User.where(slack_id: recipient_id).first_or_create(display_name: name)
  end

end
