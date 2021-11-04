require 'fileutils'
require './lib/efa/product_category_index_generator.rb'

describe EFA::ProductCategoryIndexGenerator do
  describe '#generate_output' do
    let(:file_name) { 'ProdCatIndexTT.txt' }
    let(:company) { 'efa' }
    let(:generator) do
      described_class.new(
        csv_location: "spec/fixtures/#{company}/Company_Category.csv",
        output_dir: "spec/tmp/#{company}",
      )
    end

    it 'writes the output to a file' do
      generator.generate_text
      tagged_text_output = "spec/tmp/#{company}/#{file_name}"
      fixture = "spec/fixtures/#{company}/#{file_name}"
      expect(FileUtils.compare_file(fixture, tagged_text_output)).to be_truthy
    end
  end
end