require 'spec_helper'

describe Spree::LineItem do

  describe "callbacks" do
    it { expect(subject).to callback(:create_subscription!).after(:create).if(:subscribable?) }
    it { expect(subject).to callback(:update_subscription_quantity).after(:update).if([:subscription?, :quantity_changed?]) }
    it { expect(subject).to callback(:update_subscription_attributes).after(:update).if([:subscription_attributes_present?, :subscription?]) }
    it { expect(subject).to callback(:destroy_associated_subscription!).after(:destroy).if(:subscription?) }
  end

end
