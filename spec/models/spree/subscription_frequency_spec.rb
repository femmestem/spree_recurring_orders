require "spec_helper"

describe Spree::SubscriptionFrequency do

  describe "associations" do
    it { expect(subject).to have_many(:product_subscription_frequencies).class_name("Spree::ProductSubscriptionFrequency").dependent(:destroy) }
  end

  describe "validations" do
    it { expect(subject).to validate_presence_of(:title) }
    it { expect(subject).to validate_presence_of(:months_count) }
    it { expect(subject).to validate_numericality_of(:months_count).is_greater_than(0).only_integer }
    it { expect(subject).to validate_uniqueness_of(:title).case_insensitive.allow_blank }
  end

end
