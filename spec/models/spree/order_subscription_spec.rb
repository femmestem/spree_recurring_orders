require "spec_helper"

describe Spree::OrderSubscription do

  describe "associations" do
    it { expect(subject).to belong_to(:order).class_name("Spree::Order") }
    it { expect(subject).to belong_to(:subscription).class_name("Spree::Subscription") }
  end

  describe "validations" do
    it { expect(subject).to validate_presence_of(:order) }
    it { expect(subject).to validate_presence_of(:subscription) }
    it { expect(subject).to validate_uniqueness_of(:order).scoped_to(:subscription).case_insensitive }
  end

end
