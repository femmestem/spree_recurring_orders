require 'spec_helper'

describe Spree::Order do

  describe "associations" do
    it { is_expected.to have_one(:order_subscription).class_name("Spree::OrdersSubscription").dependent(:destroy) }
  end

end
