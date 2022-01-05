require './lib/efa/companies_generator'
require './lib/efa/product_category_list_generator'
require './lib/efa/product_category_index_generator'
require './lib/impressions/suppliers_generator'
require './lib/impressions/alphabetical_index_generator'
require './lib/impressions/category_index_generator'
require './lib/impressions/cross_reference_generator'
require './lib/hcd/companies_generator'
require './lib/hcd/product_category_list_generator'
require './lib/hcd/product_category_index_generator'
require './lib/hd/product_category_list_generator'
include EFA
include Impressions
include HCD
include HD

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

  desc 'Update fixtures for Impressions tests.'
  task :update_fixtures_impressions do
    output_location = 'spec/fixtures/impressions'
    csv_location = 'spec/fixtures/impressions'

    # when 'AlphabeticalIndexTT'
    Impressions::AlphabeticalIndexGenerator.new(
      csv: "#{csv_location}/Company_Category.csv",
      output_location: output_location,
    ).generate_text

    # when 'CategoryIndexTT'
    Impressions::CategoryIndexGenerator.new(
      csv: "#{csv_location}/Company_Category.csv",
      output_location: output_location,
    ).generate_text

    # when 'CrossReferenceTT'
    Impressions::CrossReferenceGenerator.new(
      companies_csv: "#{csv_location}/Companies.csv",
      company_category_csv: "#{csv_location}/Company_Category.csv",
      output_location: output_location,
    ).generate_text

    # when 'SuppliersTT'
    Impressions::SuppliersGenerator.new(
      companies_csv: "#{csv_location}/Companies.csv",
      branches_csv: "#{csv_location}/Branches.csv",
      output_location: output_location,
    ).generate_text
  end

  desc 'Update fixtures for HCD tests.'
  task :update_fixtures_hcd do
    output_location = 'spec/fixtures/hcd'
    csv_location = 'spec/fixtures/hcd'

    # when 'CompaniesTT'
    HCD::CompaniesGenerator.new(
      csv_location: csv_location,
      csv_file_name: 'Companies',
      output_location: output_location,
      tagged_text_file_name: 'CompaniesTT',
    ).generate_text

    HCD::ProductCategoryIndexGenerator.new(
      csv_location: csv_location,
      csv_file_name: 'Categories',
      output_location: output_location,
      tagged_text_file_name: 'ProdCatIndexTT',
    ).generate_text

    HCD::ProductCategoryListGenerator.new(
      csv_location: csv_location,
      csv_file_name: 'Categories',
      output_location: output_location,
      tagged_text_file_name: 'ProdCatListTT',
    ).generate_text
  end

  desc 'Update fixtures for HD tests.'
  task :update_fixtures_hd do
    output_location = 'spec/fixtures/hd'
    csv_location = 'spec/fixtures/hd'

    # when 'CompaniesTT'
    # HD::CompaniesGenerator.new(
    #   csv_location: csv_location,
    #   csv_file_name: 'Companies',
    #   output_location: output_location,
    #   tagged_text_file_name: 'CompaniesTT',
    # ).generate_text

    HD::ProductCategoryListGenerator.new(
      csv_location: csv_location,
      csv_file_name: 'Categories',
      output_location: output_location,
      tagged_text_file_name: 'ProdCatListTT',
    ).generate_text
  end
end
