require "rails_helper"

RSpec.describe SubscriptionMailer, type: :mailer do
  describe "notify_user" do
    let(:mail) { SubscriptionMailer.notify_user }

    it "renders the headers" do
      expect(mail.subject).to eq("Notify user")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
