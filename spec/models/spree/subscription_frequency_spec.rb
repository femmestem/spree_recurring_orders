require "spec_helper"

RSpec.describe Spree::SubscriptionFrequency do

  let(:subscription_frequency_1) { build(:monthly_subscription_frequency, months_count: 3) }

  describe "associations" do
    it { expect(subject).to have_many(:product_subscription_frequencies).class_name("Spree::ProductSubscriptionFrequency").dependent(:destroy) }
  end

  describe "validations" do
    it { expect(subject).to validate_presence_of(:title) }
    it { expect(subject).to validate_presence_of(:months_count) }
    it { expect(subject).to validate_numericality_of(:months_count).is_greater_than(0).only_integer }
    context "uniqueness of title" do
      before { subscription_frequency_1.save }
      it { expect(subscription_frequency_1.errors[:title]).to include "has already been taken" }
    end
  end

end
