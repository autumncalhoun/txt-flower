require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'YAML'
require 'colorize'

require_relative '../common_format_helpers'

module Impressions
  # Output file: CrossReferenceTT.txt
  class CrossReference
    include ::CommonFormatHelpers

    def initialize(
      company_csv = './lib/impressions/Companies.csv',
      category_csv = './lib/impressions/CompanyCategory.csv'
    )
      @company_rows = CSV.read(company_csv, headers: true)
      @category_rows = CSV.read(category_csv, headers: true)
      @template = YAML.safe_load(File.open('./lib/impressions/impressions.yml'))
      @header_style = @template['cross_reference']['header']
      generate_text
    end

    def generate_text
      puts '🌻 PREPROCESS CSV: Text To Columns on the CategoryPath column!'
             .yellow
      output = File.open('./lib/impressions/CrossReferenceTT.txt', 'w')
      output << @header_style
      output << list_by_category
      output.close
    end

    def list_by_category
      categories = sorted_categories
      prod_style = @template['cross_reference']['styles']['product']
      subprod_style = @template['cross_reference']['styles']['subproduct']

      current_cat = ''
      current_prod = ''
      current_subprod = ''

      items = []
      categories.each do |row|
        category = row.field(cat_col_name('category'))
        product = row.field(cat_col_name('product'))
        subproduct = row.field(cat_col_name('subproduct'))

        if current_cat != category
          items.push('CATEGORY ' + category)
          current_cat = category
        end

        if current_prod != product
          items.push(prod_style + product)
          current_prod = product
        end

        if !subproduct.blank? && current_subprod != subproduct
          items.push(subprod_style + subproduct)
          current_subprod = subproduct
        end

        company =
          @company_rows.find do |co|
            co.field(col_name('id')) == row.field(cat_col_name('id'))
          end

        if company
          items.push(
            Company.new(
              name: company.field(col_name('name')),
              state: company.field(col_name('state')),
              phone: company.field(col_name('phone')),
              tollfree: company.field(col_name('tollfree')),
              country: company.field(col_name('country'))
            ).to_s
          )
        end
      end

      items.join(line_break)
    end

    private

    def col_name(property)
      @template['csv_headers']['companies'][property]
    end

    def cat_col_name(property)
      @template['csv_headers']['company_category'][property]
    end

    def sorted_categories
      @category_rows.sort_by do |row|
        [
          row[cat_col_name('category')],
          row[cat_col_name('product')],
          row[cat_col_name('subproduct')].to_s,
          row[cat_col_name('company_name')].downcase
        ]
      end
    end
  end

  # <ParaStyle:Company>One Stop	MI	(800) 968-7550
  class Company
    include ::CommonFormatHelpers

    def initialize(name:, state:, phone:, tollfree:, country:)
      @name = name
      @state = state
      @phone = phone
      @tollfree = tollfree
      @country = country
      @template = YAML.safe_load(File.open('./lib/impressions/impressions.yml'))
    end

    def to_s
      [formatted_name, @state, formatted_phone].compact.join(tab_space)
    end

    private

    def formatted_name
      style = @template['cross_reference']['styles']['company']
      style + @name
    end

    def formatted_phone
      return format_phone(@tollfree, @country) unless @tollfree.blank?
      format_phone(@phone, @country)
    end
  end
end

class String
  def initial
    self[0, 1]
  end
end
