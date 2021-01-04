require 'fileutils'
require './lib/impressions/suppliers'

describe Impressions::Suppliers do
  describe '#initialize' do
    it 'builds the right file' do
      Impressions::Suppliers.new(
        company_csv: 'spec/fixtures/impressions/Companies.csv',
        branch_csv: 'spec/fixtures/impressions/Branches.csv',
        output_destination: 'spec/tmp/impressions'
      )
      tagged_text = 'spec/tmp/impressions/SuppliersTT.txt'
      fixture = 'spec/fixtures/impressions/SuppliersTT.txt'
      expect(FileUtils.compare_file(fixture, tagged_text)).to be_truthy
    end
  end
end
