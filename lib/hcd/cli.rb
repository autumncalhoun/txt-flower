require 'tty-prompt'
require 'YAML'
require 'csv'
require_relative './companies_generator.rb'
require_relative './product_category_list_generator.rb'
require_relative './product_category_index_generator.rb'

module HCD
  class CLI
    def load_template
      YAML.safe_load(File.open('./lib/hcd/hcd.yml'))
    end

    def template
      @template ||= YAML.safe_load(File.open('./lib/hcd/hcd.yml'))
    end

    def company_name
      @company_name ||= 'HCD'
    end

    def text_files
      @text_files ||= template['tagged_text_files'].keys
    end

    def csv_files
      @csv_files ||= template['csv_files'].keys
    end

    def csv_headers(filename)
      template['csv_files'][filename]['csv_headers'].map { |header| header[1] }
    end

    def use_generator(file:, csv_dir:, output_dir:)
      case file
      when 'CompaniesTT_Products'
        csv = 'Companies_Products'
        HCD::CompaniesGenerator.new(
          csv_location: csv_dir,
          csv_file_name: csv,
          output_location: output_dir,
          tagged_text_file_name: file,
        ).generate_text
      when 'CompaniesTT_Services'
        csv = 'Companies_Services'
        HCD::CompaniesGenerator.new(
          csv_location: csv_dir,
          csv_file_name: csv,
          output_location: output_dir,
          tagged_text_file_name: file,
        ).generate_text
      when 'ProdCatListTT_Products'
        csv = 'Categories_Products'
        HCD::ProductCategoryListGenerator.new(
          csv_location: csv_dir,
          csv_file_name: csv,
          output_location: output_dir,
          tagged_text_file_name: file,
        ).generate_text
      when 'ProdCatListTT_Services'
        csv = 'Categories_Services'
        HCD::ProductCategoryListGenerator.new(
          csv_location: csv_dir,
          csv_file_name: csv,
          output_location: output_dir,
          tagged_text_file_name: file,
        ).generate_text
      when 'ProdCatIndexTT_Products'
        csv = 'Categories_Products'
        HCD::ProductCategoryIndexGenerator.new(
          csv_location: csv_dir,
          csv_file_name: csv,
          output_location: output_dir,
          tagged_text_file_name: file,
        ).generate_text
      when 'ProdCatIndexTT_Services'
        csv = 'Categories_Services'
        HCD::ProductCategoryIndexGenerator.new(
          csv_location: csv_dir,
          csv_file_name: csv,
          output_location: output_dir,
          tagged_text_file_name: file,
        ).generate_text
      end
    end
  end
end
