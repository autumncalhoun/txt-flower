require 'fileutils'
require './lib/impressions/cross_reference_generator'

describe Impressions::CrossReferenceGenerator do
  describe '#generate_output' do
    let(:company) { 'impressions' }
    let(:output_location) { "spec/tmp/#{company}" }
    let(:csv_location) { "spec/fixtures/#{company}" }

    let(:tagged_text_output) { "spec/tmp/#{company}/#{file_name}.txt" }
    let(:fixture) { "spec/fixtures/#{company}/#{file_name}.txt" }
    let(:file_name) { 'CrossReferenceTT' }

    let(:generator) do
      described_class.new(
        csv_location: csv_location,
        companies_csv: 'Companies',
        company_category_csv: 'Company_Category',
        output_location: output_location,
        tagged_text_file_name: 'CrossReferenceTT',
      )
    end

    it 'writes the output to a file' do
      generator.generate_text

      show_diff(fixture, tagged_text_output)
      expect(FileUtils.compare_file(fixture, tagged_text_output)).to be_truthy
    end
  end
end
