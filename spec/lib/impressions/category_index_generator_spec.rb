require 'fileutils'
require './lib/impressions/category_index_generator'

describe Impressions::CategoryIndexGenerator do
  describe '#generate_output' do
    let(:company) { 'impressions' }
    let(:output_location) { "spec/tmp/#{company}" }
    let(:csv_location) { "spec/fixtures/#{company}" }

    let(:tagged_text_output) { "spec/tmp/#{company}/#{file_name}.txt" }
    let(:fixture) { "spec/fixtures/#{company}/#{file_name}.txt" }
    let(:file_name) { 'ProdCatIndexTT' }

    let(:generator) do
      described_class.new(csv: "#{csv_location}/Company_Category.csv", output_location: output_location)
    end

    it 'writes the output to a file' do
      generator.generate_text
      expect(FileUtils.compare_file(fixture, tagged_text_output)).to be_truthy
    end
  end
end
