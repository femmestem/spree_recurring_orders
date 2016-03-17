require "spec_helper"

describe Spree::Variant, type: :model do

  describe "associations" do
    it { expect(subject).to have_many(:subscriptions).class_name("Spree::Subscription").dependent(:restrict_with_error) }
  end

end
