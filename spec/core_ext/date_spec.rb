require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe 'Date#fuzzy' do

  it 'should be "Today" if the date is today' do
    Date.today.fuzzy.should =~ /^Today/
  end

  it 'should be "Yesterday" if the date is yesterday' do
    (Date.today - 1).fuzzy.should =~ /^Yesterday/
  end

  it 'should be "Tomorrow" if the date is tomorrow' do
    (Date.today + 1).fuzzy.should =~ /^Tomorrow/
  end

  it 'should be a formatted date otherwise' do
    [Date.today - 2, Date.today + 2].each do |date|
      date.fuzzy.should =~ /^
        (Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)\s
        \d\d?   # Day number
        \w\w\s  # Ordinal
        (January|February|March|April|May|June|July|August|
         September|October|November|December)
      /x
    end
  end

end
