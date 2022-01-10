require 'tty-prompt'
require 'YAML'
require 'csv'
require_relative './companies_generator.rb'
require_relative './product_category_list_generator.rb'

module HD
  class CLI
    def load_template
      YAML.safe_load(File.open('./lib/hd/hd.yml'))
    end

    def template
      @template ||= YAML.safe_load(File.open('./lib/hd/hd.yml'))
    end

    def company_name
      @company_name ||= 'HD'
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
      when 'CompaniesTT'
        csv = 'Companies'
        HD::CompaniesGenerator.new(
          csv_location: csv_dir,
          csv_file_name: csv,
          output_location: output_dir,
          tagged_text_file_name: file,
        ).generate_text
      when 'ProdCatListTT'
        csv = 'Categories'
        HD::ProductCategoryListGenerator.new(
          csv_location: csv_dir,
          csv_file_name: csv,
          output_location: output_dir,
          tagged_text_file_name: file,
        ).generate_text
      end
    end
  end
end
