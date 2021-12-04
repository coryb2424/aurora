# frozen_string_literal: true

require 'day_tracker'

describe DayTracker do
  subject { DayTracker.new }

  it 'tracker initialized correctly' do
    expect(subject.day).to eq('mon')
  end

  describe '#day' do
    it 'returns mon when tracker is 0' do
      day_tracker = subject
      day_tracker.instance_variable_set(:@tracker, 0)

      expect(day_tracker.day).to eq('mon')
    end

    it 'returns tue when tracker is 1' do
      day_tracker = subject
      day_tracker.instance_variable_set(:@tracker, 1)

      expect(day_tracker.day).to eq('tue')
    end

    it 'returns wed when tracker is 2' do
      day_tracker = subject
      day_tracker.instance_variable_set(:@tracker, 2)

      expect(day_tracker.day).to eq('wed')
    end

    it 'returns thur when tracker is 3' do
      day_tracker = subject
      day_tracker.instance_variable_set(:@tracker, 3)

      expect(day_tracker.day).to eq('thur')
    end

    it 'returns fri when tracker is 4' do
      day_tracker = subject
      day_tracker.instance_variable_set(:@tracker, 4)

      expect(day_tracker.day).to eq('fri')
    end
  end

  describe '#next' do
    it 'increases the tracker by 1' do
      day_tracker = subject
      day_tracker.instance_variable_set(:@tracker, 0)

      day_tracker.next
      expect(day_tracker.instance_variable_get(:@tracker)).to eq(1)
    end
  end

  describe '#reset' do
    it 'resets the tracker to 0' do
      day_tracker = subject
      day_tracker.instance_variable_set(:@tracker, 5)

      day_tracker.reset
      expect(day_tracker.instance_variable_get(:@tracker)).to eq(0)
    end
  end
end
