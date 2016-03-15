require "spec_helper"

describe Spree::Product do

  describe "associations" do
    it { expect(subject).to have_many(:subscriptions).through(:variants_including_master).source(:subscriptions).dependent(:restrict_with_error) }
    it { expect(subject).to have_many(:product_subscription_frequencies).class_name("Spree::ProductSubscriptionFrequency").dependent(:destroy) }
    it { expect(subject).to have_many(:subscription_frequencies).through(:product_subscription_frequencies).dependent(:destroy) }
  end

  describe "validations" do
    context "if subscribable" do
      before { subject.subscribable = true }
      it { expect(subject).to validate_presence_of(:subscription_frequencies) }
    end
  end

  # describe "scopes" do
  #   context "subscribable" do
  #     let(:subscription_frequencies) { [create(:subscription_frequency)] }
  #     let(:subscribable_product) { create(:product, subscribable: true, subscription_frequencies: ) }

  #     it { expect(Spree::Product.subscribable).to include subscribable_product }
  #   end
  # end

end
