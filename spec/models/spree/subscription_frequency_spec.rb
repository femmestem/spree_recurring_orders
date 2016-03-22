require "spec_helper"

RSpec.describe Spree::SubscriptionFrequency, type: :model do

  describe "associations" do
    it { is_expected.to have_many(:product_subscription_frequencies).class_name("Spree::ProductSubscriptionFrequency").dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:months_count) }
    it { is_expected.to validate_numericality_of(:months_count).is_greater_than(0).only_integer }
    context "uniqueness of title" do
      let!(:subscription_frequency_1) { create(:monthly_subscription_frequency) }
      let(:subscription_frequency_2) { build(:monthly_subscription_frequency) }
      before { subscription_frequency_2.save }
      it { expect(subscription_frequency_2.errors[:title]).to include I18n.t "errors.messages.taken" }
    end
  end

end
