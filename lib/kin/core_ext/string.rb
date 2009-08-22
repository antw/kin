class String
  ##
  # Pluralises +self+ according to the +amount+.
  #
  # @param  [Integer] amount The number of things.
  # @return [String]         The pluralised word.
  #
  # @example With zero
  #   0.numericise('heffalump') # => "no heffalumps"
  #
  # @example With one
  #   1.numericise('heffalump') # => "one heffalump"
  #
  # @example With two
  #   2.numericise('heffalump') # => "2 heffalumps"
  #
  def numericise(amount)
    case amount
      when 0, nil then "no #{plural}"
      when 1      then "one #{self}"
      else             "#{amount.to_s} #{plural}"
    end
  end
end
