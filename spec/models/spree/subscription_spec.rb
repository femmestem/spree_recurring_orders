require "spec_helper"

describe Spree::Subscription do

  describe "validations" do
    it { expect(subject).to validate_presence_of(:quantity) }
    it { expect(subject).to validate_presence_of(:delivery_number) }
    it { expect(subject).to validate_presence_of(:price) }
    it { expect(subject).to validate_presence_of(:number) }
    it { expect(subject).to validate_presence_of(:variant) }
    it { expect(subject).to validate_presence_of(:parent_order) }
    it { expect(subject).to validate_presence_of(:frequency) }
    it { expect(subject).to validate_presence_of(:cancellation_reasons) }
    it { expect(subject).to validate_presence_of(:cancelled_at) }
    it { expect(subject).to validate_presence_of(:ship_address) }
    it { expect(subject).to validate_presence_of(:bill_address) }
    it { expect(subject).to validate_presence_of(:last_occurrence_at) }
    it { expect(subject).to validate_presence_of(:source) }
    it { expect(subject).to validate_numericality_of(:price).is_greater_than_or_equal_to(0).allow_nil }
    it { expect(subject).to validate_numericality_of(:quantity).is_greater_than(0).only_integer.allow_nil }
    it { expect(subject).to validate_numericality_of(:delivery_number).is_greater_than_or_equal_to(:recurring_orders_size).only_integer.allow_nil }
  end

  describe "associations" do
  end

  describe "callbacks" do
  end

  describe "scopes" do
  end

  describe "methods" do
  end

end
