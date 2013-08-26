require 'spec_helper'

describe ExpectedEvent do
	 it { should have_many :alarms }
	 it { should have_many :incoming_events }
	 it { should validate_presence_of :title }
	 it { should ensure_inclusion_of(:final_hour).in_range(1..24) }

	 it "has a valid factory" do
	 	FactoryGirl.build(:expected_event).should be_valid
	 end

	 context 'validating title' do
	 	it 'complains about illegal characters' do
	 		expected_event = ExpectedEvent.new(title: 'bß€se')
	 		expected_event.valid?
	 		expected_event.should have(1).error_on(:title)
	 	end

	 	it 'removes trailing white spaces before save' do
	 		expected_event = ExpectedEvent.new(title: ' bose    ')
	 		expected_event.save
	 		expected_event.title.should == 'bose'
	 	end
	 end

	describe "#active?" do
		it 'returns true if current time is between start date and end date' do
			subject.started_at = 1.day.ago
			subject.ended_at 	 = 1.day.from_now
			expect(subject).to be_active  # expect(subject).to be_active oder expect(subject.active?).to eql true
		end

		it 'returns false if current time is before start date' do
			subject.started_at = 1.day.from_now
			subject.ended_at = 2.days.from_now # ended_at was nil before we added it here, test failed
			expect(subject).not_to be_active
		end

		it 'returns false if current time is after end date' do
			subject.started_at = 2.days.ago
			subject.ended_at = 1.day.ago
			expect(subject).not_to be_active
		end 

		it 'returns false if either time is not set' do
			subject.started_at = nil
			subject.ended_at = nil
			expect(subject).not_to be_active
		end
	end

	describe "selected_weekdays" do
		it 'returns an empty string if no day selected' do
			expect(subject.selected_weekdays).to eql ""
		end

		it 'adds name if selected weekday is true' do
			 subject.weekday_0 = true
			 expect(subject.selected_weekdays).to eql " Mon"
		end

		it 'does not add name if selected weekday is false' do
			subject.weekday_0 = false
			expect(subject.selected_weekdays).not_to eql " Mon"
		end

		it 'adds more than one selected weekday' do
			subject.weekday_6 = true
			subject.weekday_0 = true
			expect(subject.selected_weekdays).to eql " Mon Sun"
		end
	end


end
