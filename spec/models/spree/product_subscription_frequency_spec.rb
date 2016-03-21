require "spec_helper"

describe Spree::ProductSubscriptionFrequency, type: :model do

  describe "associations" do
    it { is_expected.to belong_to(:product).class_name("Spree::Product") }
    it { is_expected.to belong_to(:subscription_frequency).class_name("Spree::SubscriptionFrequency") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:product) }
    it { is_expected.to validate_presence_of(:subscription_frequency) }
  end

end
