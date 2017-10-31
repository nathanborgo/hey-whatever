require_relative 'spec_helper.rb'

describe Taco do
  before do
    # Whatever.
    Taco.destroy_all
  end

  after do
    Taco.destroy_all
  end

  describe "#users_cannot_give_to_themselves" do
    it "lets people give tacos to other people" do
      taco = Taco.new(
        giver_id: "U3LADN8LA",
        recipient_id: "U3LADN8LB",
      )

      taco.valid?.must_equal true
    end

    it "prevents people from giving tacos to themselves" do
      taco = Taco.new(
        giver_id: "U3LADN8LA",
        recipient_id: "U3LADN8LA",
      )

      taco.valid?.must_equal false
    end
  end

  describe "#users_cannot_give_more_than_five" do
    it "lets people give five tacos to other people" do
      4.times do
        Taco.create(
          giver_id: "U3LADN8LA",
          recipient_id: "U3LADN8LB",
        )
      end
      taco = Taco.new(
        giver_id: "U3LADN8LA",
        recipient_id: "U3LADN8LB",
      )

      taco.valid?.must_equal true
    end

    it "prevents people from giving more than five tacos to other people" do
      5.times do
        Taco.create(
          giver_id: "U3LADN8LA",
          recipient_id: "U3LADN8LB",
        )
      end
      taco = Taco.new(
        giver_id: "U3LADN8LA",
        recipient_id: "U3LADN8LB",
      )

      taco.valid?.must_equal false
    end
  end
end

