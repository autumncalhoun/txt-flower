require 'tty-prompt'
require 'YAML'
require 'csv'
require_relative './suppliers_generator.rb'
require_relative './alphabetical_index_generator.rb'
require_relative './cross_reference_generator.rb'
require_relative './category_index_generator.rb'

module Impressions
  class CLI
    def template
      @template ||= YAML.safe_load(File.open('./lib/impressions/impressions.yml'))
    end

    def company_name
      @company_name ||= 'Impressions'
    end

    def text_files
      @text_files ||= template['tagged_text_files']
    end

    def csv_files
      @csv_files ||= template['csv_files']
    end

    def csv_headers(filename)
      template['csv_headers'][filename.downcase].map { |header| header[1] }
    end

    def use_generator(file:, csv_dir:, output_dir:)
      case file
      when 'AlphabeticalIndexTT'
        Impressions::AlphabeticalIndexGenerator.new(csv: "#{csv_dir}/Company_Category.csv", output_location: output_dir)
          .generate_text
      when 'CategoryIndexTT'
        Impressions::CategoryIndexGenerator.new(csv: "#{csv_dir}/Company_Category.csv", output_location: output_dir)
          .generate_text
      when 'CrossReferenceTT'
        Impressions::CrossReferenceGenerator.new(
          companies_csv: "#{csv_dir}/Companies.csv",
          company_category_csv: "#{csv_dir}/Company_Category.csv",
          output_location: output_dir,
        ).generate_text
      when 'SuppliersTT'
        Impressions::SuppliersGenerator.new(
          companies_csv: "#{csv_dir}/Companies.csv",
          branches_csv: "#{csv_dir}/Branches.csv",
          output_location: output_dir,
        ).generate_text
      end
    end
  end
end
