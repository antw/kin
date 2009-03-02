class FakeModel
  attr_accessor :foo, :bad

  def id
    1337
  end

  def valid?
    true
  end

  def new_record?
    false
  end

  def errors
    FakeErrors.new(self)
  end
end
