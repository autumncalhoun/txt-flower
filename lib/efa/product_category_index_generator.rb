require 'pry'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'YAML'
require 'fileutils'

module EFA
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
      template = YAML.safe_load(File.open('./lib/efa/efa.yml')).deep_symbolize_keys
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

    # This is a list of Product Categories. Under each Category are subcategories.
    # be sure to list all subcategories, even if they match the category's name.
    def cat_loop
      # sort by cat, then subcat, then sub subcat
      current_cat = ''
      current_subcat = ''

      category_rows.each do |c|
        # Loop through and write the cat, subcat or subsubcat if it has not already been written (so it is unique)
        cat = c['CategoryPath'].split('->')[0]
        subcat = c['CategoryName'] || ''

        if current_cat != cat
          output << category_tag + cat + line_break
          current_cat = cat
        end

        if current_subcat != subcat
          output << tags[:product] + subcat + "\t" + line_break
          current_subcat = subcat
        end
      end

      output
    end

    def category_tag
      tags[:category]
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
