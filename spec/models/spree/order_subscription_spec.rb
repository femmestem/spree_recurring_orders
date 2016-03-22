require "spec_helper"

describe Spree::OrderSubscription, type: :model do

  describe "associations" do
    it { is_expected.to belong_to(:order).class_name("Spree::Order") }
    it { is_expected.to belong_to(:subscription).class_name("Spree::Subscription") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:order) }
    it { is_expected.to validate_presence_of(:subscription) }
    it { is_expected.to validate_uniqueness_of(:order_id).scoped_to(:subscription_id) }
  end

end
