require "spec_helper"

describe Spree::Product, type: :model do

  describe "associations" do
    it { is_expected.to have_many(:subscriptions).through(:variants_including_master).source(:subscriptions).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:product_subscription_frequencies).class_name("Spree::ProductSubscriptionFrequency").dependent(:destroy) }
    it { is_expected.to have_many(:subscription_frequencies).through(:product_subscription_frequencies).dependent(:destroy) }
  end

  describe "validations" do
    context "if subscribable" do
      before { subject.subscribable = true }
      it { is_expected.to validate_presence_of(:subscription_frequencies) }
    end
  end

  describe "scopes" do
    context ".subscribable" do
      let(:subscription_frequencies) { [create(:monthly_subscription_frequency)] }
      let(:subscribable_product) { create(:product, subscribable: true, subscription_frequencies: subscription_frequencies) }
      let(:unsubscribable_product) { create(:product) }
      it { expect(Spree::Product.subscribable).to include subscribable_product }
      it { expect(Spree::Product.subscribable).to_not include unsubscribable_product }
    end
  end

  describe "ransackable" do
    context "whitelisted_ransackable_attributes" do
      it { expect(Spree::Product.whitelisted_ransackable_attributes).to include "is_subscribable" }
    end
  end

end
