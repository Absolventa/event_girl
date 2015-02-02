require 'spec_helper'

describe Alarm, :type => :model do

  context "Validations" do

    it { is_expected.to have_many(:alarm_mappings).dependent(:destroy) }
    it { is_expected.to have_many(:expected_events).through :alarm_mappings}
    it { is_expected.to allow_value("a@b.com").for(:recipient_email) }

    it "has a valid factory" do
      expect(FactoryGirl.build(:alarm)).to be_valid
    end

    it 'allows available values from the constant' do
      Alarm::ACTIONS.each do |v|
        is_expected.to allow_value(v).for(:action)
      end
    end

    it 'does not allow other values than those in the constant' do
      Alarm::ACTIONS.each do |v|
        is_expected.not_to allow_value("other").for(:action)
      end
    end

    context 'as a webhook' do
      before { subject.action = 'Webhook' }

      it { is_expected.to validate_presence_of :target }
    end
  end

  describe '#kind' do
    shared_examples_for 'action predicate' do |action|
      let(:predicate) { "be_#{action.downcase}" }

      describe "#kind.#{action}?" do
        it "returns true for matching action" do
          subject.action = action
          expect(subject.kind).to send(predicate)
        end

        it "returns false" do
          subject.action = Alarm::ACTIONS.select{|a| a != action}.sample
          expect(subject.kind).not_to send(predicate)
        end
      end
    end

    it_behaves_like 'action predicate', 'logger'
    it_behaves_like 'action predicate', 'email'
    it_behaves_like 'action predicate', 'webhook'
  end

  context "#run" do
    let(:expected_event) { FactoryGirl.build(:expected_event) }

    it 'requires an expected_event as argument' do
      expect(subject.method(:run).arity).to eql 1
    end

    it 'sends an email when email is selected' do
      subject = FactoryGirl.create(:alarm)
      subject.action = 'email'
      expect { subject.run expected_event }.to \
        change { ActionMailer::Base.deliveries.size }.by(1)
    end

    it 'sends a logger message when logger is selected' do
      expect(Rails.logger).to receive(:info)
      subject.action = 'Logger'
      subject.run expected_event
    end
  end
end
