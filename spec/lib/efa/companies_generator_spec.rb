require 'fileutils'
require './lib/efa/companies_generator'

describe EFA::CompaniesGenerator do
  describe '#generate_output' do
    let(:generator) { EFA::CompaniesGenerator.new(csv_location: 'spec/fixtures/efa/Companies.csv', output_dir: '') }
    it 'transform csv input to string' do
      expect(generator.generate_output).to eq("1908 , 88/10, Adver, Lord , Beyon, Ad Eg, Reven, Cash , Barki, Break, ENNOV, Innov, There, ALELL, Space, Engin, HUMBL, Jolie, McTom, Humbl, Build, Decor, Fifth, Sight")
    end
  end
end