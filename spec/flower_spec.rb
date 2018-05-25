require 'flower'

describe Flower do
  describe '#initialize' do
    before(:each) do
      @sample = Flower.new
    end

    it 'sets the line break' do
      expect(@sample.instance_variable_get(:@line_break)).to eq "\n"
    end
  end

  describe '#generate_text' do
    before(:each) do
      @sample = Flower.new
      @sample.generate_text
    end

    it 'updates the output variable' do
      expect(@sample.instance_variable_get(:@output)).not_to be_empty
    end
  end
end
