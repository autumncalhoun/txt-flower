require 'fileutils'
require './lib/efa/companies_generator'

describe EFA::CompaniesGenerator do
  describe '#generate_output' do
    let(:generator) { EFA::CompaniesGenerator.new(
        csv_location: 'spec/fixtures/efa/Companies.csv',
        output_dir: 'spec/tmp/efa'
      )) }

    it 'writes the output to a file' do
      generator.generate_text
      tagged_text_output = 'spec/tmp/efa/CompaniesTT.txt'
      fixture = 'spec/fixtures/efa/CompaniesTT.txt'
      expect(FileUtils.compare_file(fixture, tagged_text_output)).to be_truthy
    end
  end
end
