require './lib/efa/companies_generator'
require './lib/efa/product_category_list_generator'
require './lib/efa/product_category_index_generator'
include EFA

namespace :test do
  desc 'Update fixtures for EFA tests.'
  task :update_fixtures_efa do
    output_location = 'spec/fixtures/efa'
    csv_location = 'spec/fixtures/efa'

    EFA::CompaniesGenerator.new(
      csv_location: csv_location,
      csv_file_name: 'Companies',
      output_location: output_location,
      tagged_text_file_name: 'CompaniesTT',
    ).generate_text

    EFA::ProductCategoryListGenerator.new(
      csv_location: csv_location,
      csv_file_name: 'Company_Category_Products',
      output_location: output_location,
      tagged_text_file_name: 'ProdCatListTT_Products',
    ).generate_text

    EFA::ProductCategoryListGenerator.new(
      csv_location: csv_location,
      csv_file_name: 'Company_Category_Services',
      output_location: output_location,
      tagged_text_file_name: 'ProdCatListTT_Services',
    ).generate_text

    EFA::ProductCategoryIndexGenerator.new(
      csv_location: csv_location,
      csv_file_name: 'Company_Category_Products',
      output_location: output_location,
      tagged_text_file_name: 'ProdCatIndexTT_Products',
    ).generate_text

    EFA::ProductCategoryIndexGenerator.new(
      csv_location: csv_location,
      csv_file_name: 'Company_Category_Services',
      output_location: output_location,
      tagged_text_file_name: 'ProdCatIndexTT_Services',
    ).generate_text
  end
end
