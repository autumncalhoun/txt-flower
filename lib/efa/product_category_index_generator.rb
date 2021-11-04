require 'pry'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'YAML'
require 'fileutils'

module EFA
  class ProductCategoryIndexGenerator
    attr_accessor :output_dir, :output, :category_rows, :line_break, :tags, :csv_headers
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
      cat_loop
      write_output_to_file
    end

    private

    def write_output_to_file
      FileUtils.mkdir_p output_dir unless Dir.exist? output_dir
      file = File.open(File.join(output_dir, 'ProdCatIndexTT.txt'), 'w')
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
          output << tags[:category] + cat + line_break
          current_cat = cat
        end

        if current_subcat != subcat
          output << tags[:product] + subcat + "\t" + line_break
          current_subcat = subcat
        end
      end

      output
    end

    def set_headers_from_yml(template)
      template[:csv_files][:Company_Category][:csv_headers]
    end

    def set_tags_from_yml(template)
      find_defs(template)[:tags]
    end

    def find_defs(template)
      template[:tagged_text_files][:ProdCatIndexTT]
    end
  end
end
