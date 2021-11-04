require './lib/efa/companies_generator'
require './lib/efa/product_category_list_generator'
require './lib/efa/product_category_index_generator'
include EFA

namespace :test do
  desc 'Update fixtures for EFA tests.'
  task :update_fixtures_efa do
    output_dir = 'spec/fixtures/efa'
    csv_path = 'spec/fixtures/efa'
    EFA::CompaniesGenerator.new(csv_location: "#{csv_path}/Companies.csv", output_dir: output_dir).generate_text
    EFA::ProductCategoryListGenerator.new(csv_location: "#{csv_path}/Company_Category.csv", output_dir: output_dir)
      .generate_text
    EFA::ProductCategoryIndexGenerator.new(csv_location: "#{csv_path}/Company_Category.csv", output_dir: output_dir)
      .generate_text
  end
end
