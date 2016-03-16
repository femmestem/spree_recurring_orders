require 'spec_helper'

describe Spree::LineItem do

  describe "callbacks" do
    it { expect(subject).to callback(:create_subscription!).after(:create).if(:subscribable?) }
    it { expect(subject).to callback(:update_subscription_quantity).after(:update).if(:can_update_subscription_quantity?) }
    it { expect(subject).to callback(:update_subscription_attributes).after(:update).if(:can_update_subscription_attributes?) }
    it { expect(subject).to callback(:destroy_associated_subscription!).after(:destroy).if(:subscription?) }
  end

  describe "attr_accessors" do
    it { expect(subject).to respond_to :delivery_number }
    it { expect(subject).to respond_to :delivery_number= }
    it { expect(subject).to respond_to :subscribe }
    it { expect(subject).to respond_to :subscribe= }
    it { expect(subject).to respond_to :subscription_frequency_id }
    it { expect(subject).to respond_to :subscription_frequency_id= }
  end

end
