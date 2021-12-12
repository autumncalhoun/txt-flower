require 'pry'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'YAML'
require 'fileutils'

module HCD
  class ProductCategoryIndexGenerator
    attr_accessor :output_location,
                  :csv_location,
                  :tagged_text_file_name,
                  :csv_file_name,
                  :output,
                  :category_rows,
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

    def cat_loop
      # sort by cat, then subcat, then sub subcat
      cat_index = category_rows

      current_cat = ''
      current_subcat = ''

      category_info = {}
      cat_index.each do |row|
        cat = row[parent_cat_field]
        subcat = row[cat_field] || ''

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
        # Loop through and write the cat, subcat or subsubcat if it has not already been written (so it is unique)
        cat = c[parent_cat_field]
        subcat = c[cat_field] || ''

        if current_cat != cat
          output << tags[:category] + cat + line_break
          current_cat = cat
        end

        # If there is only one subcategory for this category and it matches the current cat name, don't write the title
        # Otherwise write it, even if it's the same as the current category

        if subcat != cat && category_info[cat][:subcats].length == 1
          pp "[CHECK] Unusual Category/Single Subcategory: #{cat} - #{subcat}"
        end

        pp "[CHECK] Single Subcategory: #{cat} - #{subcat}" if category_info[cat][:subcats].length == 1

        if current_subcat != subcat && (subcat != cat || category_info[cat][:subcats].length > 1)
          pp "[CHECK] Subcat matches parent cat: #{cat} - #{subcat}" if subcat == cat
          output << tags[:product] + subcat + "\t" + line_break
          current_subcat = subcat
        end
      end

      return output
    end

    def cat_field
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
