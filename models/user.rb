class User < ActiveRecord::Base

  def taco_count
    Taco.where(recipient_id: slack_id).count
  end

end
