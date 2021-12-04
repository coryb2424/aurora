# frozen_string_literal: true

# Class which tracks what day of the week the scheduler is looking at
class DayTracker
  WEEK_DAY = %w[mon tue wed thur fri n/a].freeze

  def initialize
    @tracker = 0
  end

  def next
    @tracker += 1 unless @tracker == 5
    day
  end

  def day
    WEEK_DAY[@tracker]
  end

  def reset
    @tracker = 0
  end
end
