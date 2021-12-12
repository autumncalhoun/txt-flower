require 'pry'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'YAML'
require 'fileutils'

module HCD
  class ProductCategoryListGenerator
    attr_accessor :output_location,
                  :csv_location,
                  :tagged_text_file_name,
                  :csv_file_name,
                  :category_rows,
                  :output,
                  :line_break,
                  :tags,
                  :csv_headers

    def initialize(csv_location:, output_location:, tagged_text_file_name:, csv_file_name:)
      @output_location = output_location
      @csv_location = csv_location
      @csv_file_name = csv_file_name
      @tagged_text_file_name = tagged_text_file_name

      @category_rows = CSV.read("#{csv_location}/#{csv_file_name}.csv", headers: true)
      template = YAML.safe_load(File.open('./lib/hcd/hcd.yml')).deep_symbolize_keys
      @tags = set_tags_from_yml(template)
      @csv_headers = set_headers_from_yml(template)
      @output = ''
      @line_break = "\n"
    end

    def generate_text
      prod_cat_loop
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

    def prod_cat_loop
      cat_index = category_rows

      current_cat = ''
      current_subcat = ''

      cat_index.each do |c|
        # Loop through and write the cat, subcat or subsubcat if it has not already been written (so it is unique)
        cat = c[parent_cat_field]
        subcat = c[category_field] || ''
        company = c[company_field]

        if current_cat != cat
          output << head_tag + cat + @line_break

          output << company_tag + company + @line_break if cat == subcat

          current_cat = cat
        end

        if current_subcat != subcat
          output << head2_tag + subcat + @line_break

          current_subcat = subcat
        end

        output << company_tag + company + @line_break
      end

      return output
    end

    def head_tag
      tags[:head]
    end

    def head2_tag
      tags[:head2]
    end

    def company_tag
      tags[:company]
    end

    def company_field
      csv_headers[:company_name]
    end

    def category_field
      csv_headers[:category]
    end

    def parent_cat_field
      csv_headers[:parent_category]
    end

    def set_headers_from_yml(template)
      template[:csv_files][csv_file_name.to_sym][:csv_headers]
    end

    def set_tags_from_yml(template)
      find_defs(template)[:tags]
    end

    def find_defs(template)
      template[:tagged_text_files][tagged_text_file_name.to_sym]
    end
  end
end
