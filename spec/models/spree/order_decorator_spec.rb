require 'spec_helper'

describe Spree::Order do

  describe "associations" do
    it { expect(subject).to have_one(:order_subscription).class_name("Spree::OrderSubscription").dependent(:destroy) }
    it { expect(subject).to have_one(:parent_subscription).through(:order_subscription).source(:subscription) }
    it { expect(subject).to have_many(:subscriptions).class_name("Spree::Subscription").with_foreign_key(:parent_order_id).dependent(:restrict_with_error) }
  end

  describe "callbacks" do
    it { expect(subject).to callback(:update_subscriptions).after(:update) }
  end

  describe "methods" do
    context "#available_payment_methods" do

    end
  end

end
