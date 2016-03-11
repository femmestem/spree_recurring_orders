require "spec_helper"

RSpec.describe Spree::SubscriptionFrequency do

  let!(:subscription_frequency_1) { create(:monthly_subscription_frequency) }
  let(:subscription_frequency_2) { build(:monthly_subscription_frequency, months_count: 3) }

  describe "associations" do
    it { expect(subject).to have_many(:product_subscription_frequencies).class_name("Spree::ProductSubscriptionFrequency").dependent(:destroy) }
  end

  describe "validations" do
    it { expect(subject).to validate_presence_of(:title) }
    it { expect(subject).to validate_presence_of(:months_count) }
    it { expect(subject).to validate_numericality_of(:months_count).is_greater_than(0).only_integer }
    context "uniqueness of title" do
      before do
        subscription_frequency.save
      end
      it { expect(subscription_frequency.errors[:title]).to include "has been already taken" }
    end
  end

end
