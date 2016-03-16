require "spec_helper"

describe Spree::PaymentMethod do

  describe "scopes" do
    let(:active_payment_method) { create(:credit_card_payment_method, active: true) }
    let(:unactive_payment_method) { create(:credit_card_payment_method, active: false) }
    it { expect(Spree::PaymentMethod.active).to include active_payment_method }
    it { expect(Spree::PaymentMethod.active).to_not include unactive_payment_method }
  end

end
