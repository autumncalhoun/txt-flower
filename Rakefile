require './lib/efa/companies_generator'
include EFA

namespace :test do
  desc 'Update fixtures for EFA tests.'
  task :update_fixtures_efa do
    EFA::CompaniesGenerator.new(csv_location: 'spec/fixtures/efa/Companies.csv', output_dir: 'spec/fixtures/efa')
      .generate_text
  end
end
