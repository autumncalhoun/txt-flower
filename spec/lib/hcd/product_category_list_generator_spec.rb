require 'fileutils'
require './lib/hcd/product_category_list_generator.rb'

describe HCD::ProductCategoryListGenerator do
  describe '#generate_output' do
    let(:company) { 'hcd' }
    let(:output_location) { "spec/tmp/#{company}" }
    let(:csv_location) { "spec/fixtures/#{company}" }
    let(:tagged_text_output) { "spec/tmp/#{company}/#{file_name}.txt" }
    let(:fixture) { "spec/fixtures/#{company}/#{file_name}.txt" }
    let(:generator) do
      described_class.new(
        csv_location: csv_location,
        csv_file_name: csv_name,
        output_location: output_location,
        tagged_text_file_name: file_name,
      )
    end

    describe 'ProductCatListTT' do
      let(:file_name) { 'ProdCatListTT' }
      let(:csv_name) { 'Categories' }
      it 'writes the output to a file' do
        generator.generate_text

        # show_diff(fixture, tagged_text_output)
        expect(FileUtils.compare_file(fixture, tagged_text_output)).to be_truthy
      end
    end
  end
end
