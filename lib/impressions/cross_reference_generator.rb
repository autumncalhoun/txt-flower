require 'pry'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'Phony'
require 'Phone'
require 'YAML'
require 'fileutils'

require_relative '../phone_number.rb'

module Impressions
  class CrossReferenceGenerator
    attr_accessor :output_location,
                  :tagged_text_file_name,
                  :output,
                  :line_break,
                  :tags,
                  :csv_headers,
                  :category_data,
                  :company_data
    def initialize(csv_location:, company_category_csv:, companies_csv:, output_location:, tagged_text_file_name:)
      @csv_location = csv_location
      @output_location = output_location
      @tagged_text_file_name = tagged_text_file_name
      @category_data = CSV.read("#{csv_location}/#{company_category_csv}.csv", headers: true)
      @company_data = CSV.read("#{csv_location}/#{companies_csv}.csv", headers: true)
      template = YAML.safe_load(File.open('./lib/impressions/impressions.yml')).deep_symbolize_keys
      @tags = set_tags_from_yml(template)
      @csv_headers = set_csv_headers_from_yml(template, company_category_csv, companies_csv)
      @output = ''
      @line_break = "\n"
    end

    def generate_text
      cat_loop
      write_output_to_file
    end

    private

    def write_output_to_file
      FileUtils.mkdir_p output_location unless Dir.exist? output_location
      file = File.open(File.join(output_location, "#{tagged_text_file_name}.txt"), 'w')
      file << tags[:header]
      file << output
      file.close
    end

    def phone(item)
      number = item[company_tollfree_field] || item[company_phone_field]
      PhoneNumber.new(number: number, country: item[company_country_field].to_s).format
    end

    def get_company(cat)
      c = company_data.select { |co| co[company_id_field] == cat[company_id_field] }.first
      return '' unless c
      phone_num = phone(c)

      company_tag + c[company_name_field].to_s + "\t" + c[company_state_field].to_s + "\t" + phone_num + line_break
    end

    def cat_loop
      cat_index =
        category_data.sort_by do |d|
          [d[category_field], d[product_field], d[subproduct_field].to_s, d[category_company_name_field].to_s.downcase]
        end

      current_cat = ''
      current_prod = ''
      current_subprod = ''

      cat_index.each do |c|
        # Loop through and write the cat, subcat or subsubcat if it has not already been written (so it is unique)
        cat = c[category_field]
        prod = c[product_field] || ''
        subprod = c[subproduct_field] || ''
        listing = c[listing_field]

        if current_cat != cat
          output << 'CATEGORY ' + cat + line_break
          current_cat = cat
        end

        if current_prod != prod
          output << product_tag + prod + line_break
          current_prod = prod
        end

        output << get_company(c) if prod == listing

        if !subprod.blank? && current_subprod != subprod
          output << subproduct_tag + subprod + line_break

          current_subprod = subprod
        end

        output << get_company(c) if subprod == listing
      end

      return output
    end

    def company_name_field
      csv_headers[:name]
    end

    def category_company_name_field
      csv_headers[:company_name]
    end

    def company_state_field
      csv_headers[:state]
    end

    def company_tollfree_field
      csv_headers[:tollfree]
    end

    def company_phone_field
      csv_headers[:phone]
    end

    def company_country_field
      csv_headers[:country]
    end

    def category_field
      csv_headers[:category]
    end

    def product_field
      csv_headers[:product]
    end

    def subproduct_field
      csv_headers[:subproduct]
    end

    def listing_field
      csv_headers[:listing]
    end

    def company_id_field
      csv_headers[:id]
    end

    def company_tag
      tags[:company]
    end

    def product_tag
      tags[:product]
    end

    def subproduct_tag
      tags[:subproduct]
    end

    def set_csv_headers_from_yml(template, company_category_csv, companies_csv)
      company_category_headers = template[:csv_files][company_category_csv.to_sym][:csv_headers]
      companies_headers = template[:csv_files][companies_csv.to_sym][:csv_headers]
      company_category_headers.merge(companies_headers)
    end

    def set_tags_from_yml(template)
      find_defs(template)[:tags]
    end

    def find_defs(template)
      template[:tagged_text_files][tagged_text_file_name.to_sym]
    end
  end
end
