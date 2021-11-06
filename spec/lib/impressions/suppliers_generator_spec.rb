require 'fileutils'
require './lib/impressions/suppliers_generator'

describe Impressions::SuppliersGenerator do
  describe '#generate_output' do
    let(:company) { 'impressions' }
    let(:output_location) { "spec/tmp/#{company}" }
    let(:csv_location) { "spec/fixtures/#{company}" }
    let(:tagged_text_output) { "spec/tmp/#{company}/#{file_name}.txt" }
    let(:fixture) { "spec/fixtures/#{company}/#{file_name}.txt" }
    let(:file_name) { 'SuppliersTT' }

    # Impressions::SuppliersGenerator.new(
    #     companies_csv: "#{csv_dir}/Companies.csv",
    #     branches_csv: "#{csv_dir}/Branches.csv",
    #     output_location: output_dir,
    #   ).generate_text
    let(:generator) do
      described_class.new(
        companies_csv: "#{csv_location}/Companies.csv",
        branches_csv: "#{csv_location}/Branches.csv",
        output_location: output_location,
      )
    end

    it 'writes the output to a file' do
      generator.generate_text
      expect(FileUtils.compare_file(fixture, tagged_text_output)).to be_truthy
    end
  end
end
