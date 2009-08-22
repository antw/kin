class Date
  ##
  # Fuzzy-formats the date. If the date is yesterday, today or tomorrow, a
  # simpler date will be given.
  #
  # @return [String]
  #
  # @example Today.
  #   Date.today.fuzzy # => "Today"
  #
  # @example Some time ago.
  #   (Date.today - 7).fuzzy # => "Wednesday 29th July"
  #
  def fuzzy
    today = Date.today

    case self
      when today     then 'Today'
      when today - 1 then 'Yesterday'
      when today + 1 then 'Tomorrow'
      else                 to_ordinalized_s(:date_only)
    end
  end
end
