require 'pry'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'YAML'
require 'fileutils'

module HD
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
      template = YAML.safe_load(File.open('./lib/hd/hd.yml')).deep_symbolize_keys
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
      # sort by prod, then subproduct, then company name without "the "
      cat_index =
        category_rows.sort_by do |c|
          company_name = c['CompanyName'].downcase
          company_name = company_name.start_with?('the ') ? company_name.split('the ').last : company_name
          [c['CategoryPath'].downcase, c['CategoryName'].downcase, company_name]
        end

      current_cat = ''
      current_subcat = ''

      # Loop through the category. If the category only has one subcategory, don't write the subcat.
      # If it has more than one subcategory, write them all.
      # {
      #   'Electronics': {
      #     subcats: []
      #   }
      # }

      category_info = {}
      unusual_categories = []
      cat_index.each do |row|
        cat = row['CategoryPath']
        subcat = row['CategoryName'] || ''

        if current_cat != cat
          category_info[cat] = { subcats: [] }
          current_cat = cat
        end

        if current_subcat != subcat
          category_info[cat][:subcats].push(subcat)
          current_subcat = subcat
        end
      end

      cat_index.each do |c|
        # Loop through and write the cat, subcat if it has not already been written (so it is unique)
        cat = c['CategoryPath']
        subcat = c['CategoryName'] || ''
        company = c['CompanyName']

        if current_cat != cat
          output << tags[:head] + cat + line_break
          current_cat = cat
          current_subcat = '' # reset the subcat when the cat changes
        end

        # If there is only one subcategory for this category and it matches the current cat name, don't write the title
        # Otherwise write it, even if it's the same as the current category

        unusual_categories.push cat if subcat == cat && category_info[cat][:subcats].length == 1

        if current_subcat != subcat && (subcat != cat || category_info[cat][:subcats].length > 1)
          output << tags[:head2] + subcat + line_break
          current_subcat = subcat
        end

        output << tags[:company] + company + line_break
      end

      pp unusual_categories.uniq
      pp "DON'T FORGET TO CHECK THESE CATEGORIES - they only have one subcategory and it is the same as the main category"
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
