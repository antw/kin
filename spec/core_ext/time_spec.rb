require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe 'Time#fuzzy' do
  describe 'when the time is today' do
    before { @time = Time.now }

    it 'should begin with "Today"' do
      @time.fuzzy.should =~ /^Today/
    end

    it 'should include the time' do
      @time.fuzzy.should =~ /#{@time.strftime('%H:%M')}$/
    end
  end

  describe 'when the time is tomorrow' do
    before { @time = 1.day.from_now }

    it 'should begin with "Tomorrow"' do
      @time.fuzzy.should =~ /^Tomorrow/
    end

    it 'should include the time' do
      @time.fuzzy.should =~ /#{@time.strftime('%H:%M')}$/
    end
  end

  describe 'when the time is yesterday' do
    before { @time = 1.day.ago }

    it 'should begin with "Yesterday"' do
      @time.fuzzy.should =~ /^Yesterday/
    end

    it 'should include the time' do
      @time.fuzzy.should =~ /#{@time.strftime('%H:%M')}$/
    end
  end

  describe 'when the time is yesterday + 1 day' do
    before { @time = 2.days.from_now }

    it 'should begin with the formatted date' do
      @time.fuzzy.should =~ /^
        (Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)\s
        \d\d?   # Day number
        \w\w\s  # Ordinal
        (January|February|March|April|May|June|July|August|
         September|October|November|December)
      /x
    end

    it 'should include the time' do
      @time.fuzzy.should =~ /#{@time.strftime('%H:%M')}$/
    end
  end

  describe 'when the time is yesterday - 1 day' do
    before { @time = 2.days.ago }

    it 'should begin with the formatted date' do
      @time.fuzzy.should =~ /^
        (Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)\s
        \d\d?   # Day number
        \w\w\s  # Ordinal
        (January|February|March|April|May|June|July|August|
         September|October|November|December)
      /x
    end

    it 'should include the time' do
      @time.fuzzy.should =~ /#{@time.strftime('%H:%M')}$/
    end
  end
end
