require 'pry'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'YAML'
require 'fileutils'

module EFA
  class ProductCategoryListGenerator
    attr_accessor :output_dir, :category_rows, :output, :line_break, :tags, :csv_headers
    def initialize(csv_location:, output_dir:)
      @output_dir = output_dir
      @category_rows = CSV.read(csv_location, headers: true)
      template = YAML.safe_load(File.open('./lib/efa/efa.yml')).deep_symbolize_keys
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
      FileUtils.mkdir_p output_dir unless Dir.exist? output_dir
      file = File.open(File.join(output_dir, 'ProdCatListTT.txt'), 'w')
      file << tags[:header]
      file << output
      file.close
    end

    def prod_cat_loop
      cat_index = category_rows # data is already sorted
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
      cat_index.each do |row|
        cat = row[parent_cat_field]
        subcat = row[category_field] || ''

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
        cat = c[parent_cat_field]
        subcat = c[category_field] || ''
        company = c[company_field]

        if current_cat != cat
          output << tags[:head] + cat + line_break
          current_cat = cat
          current_subcat = '' # reset the subcat when the cat changes
        end

        # If there is only one subcategory for this category and it matches the current cat name, don't write the title
        # Otherwise write it, even if it's the same as the current category
        if subcat == cat && category_info[cat][:subcats].length == 1
          pp "Unusual Category/Subcategory: #{cat} - #{subcat}"
        end

        if current_subcat != subcat
          output << tags[:head2] + subcat + line_break
          current_subcat = subcat
        end

        output << tags[:company] + company + line_break
      end
      output
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
      template[:csv_files][:Company_Category][:csv_headers]
    end

    def set_tags_from_yml(template)
      find_defs(template)[:tags]
    end

    def find_defs(template)
      template[:tagged_text_files][:ProdCatListTT]
    end
  end
end
