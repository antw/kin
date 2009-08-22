require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe 'String#numericise' do
  describe 'when given nil' do
    it 'should begin with "no"' do
      'word'.numericise(nil).should =~ /^no/
    end

    it 'should pluralise the word' do
      'word'.numericise(nil).should =~ /words$/
    end
  end

  describe 'when given 0' do
    it 'should begin with "no"' do
      'word'.numericise(0).should =~ /^no/
    end

    it 'should pluralise the word' do
      'word'.numericise(0).should =~ /words$/
    end
  end

  describe 'when given 1' do
    it 'should begin with "one"' do
      'word'.numericise(1).should =~ /^one/
    end

    it 'should not pluralise the word' do
      'word'.numericise(1).should =~ /word$/
    end
  end

  describe 'when given > 1' do
    it 'should begin with the number' do
      'word'.numericise(2).should =~ /^2/
    end

    it 'should pluralise the word' do
      'word'.numericise(2).should =~ /words$/
    end
  end
end
