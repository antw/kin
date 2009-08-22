class Time
  ##
  # Fuzzy-formats the time. If the date is yesterday, today or tomorrow, a
  # simpler date will be given.
  #
  # @return [String]
  #
  # @example Today.
  #   Time.now.fuzzy # => "Today at 19:05"
  #
  # @example Some time ago.
  #   1.week.ago.fuzzy # => "Wednesday 29th July at 19:05"
  #
  def fuzzy
    "#{to_date.fuzzy} #{formatted(:time)}"
  end
end
