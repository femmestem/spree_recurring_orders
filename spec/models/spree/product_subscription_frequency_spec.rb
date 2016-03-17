require "spec_helper"

describe Spree::ProductSubscriptionFrequency, type: :model do

  describe "associations" do
    it { expect(subject).to belong_to(:product).class_name("Spree::Product") }
    it { expect(subject).to belong_to(:subscription_frequency).class_name("Spree::SubscriptionFrequency") }
  end

  describe "validations" do
    it { expect(subject).to validate_presence_of(:product) }
    it { expect(subject).to validate_presence_of(:subscription_frequency) }
  end

end
