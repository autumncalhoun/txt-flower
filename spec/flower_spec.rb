require 'flower'

describe Flower do
  describe '#initialize' do
    it 'generates text' do
      expect('something').to eq 'something'
    end
  end
end
