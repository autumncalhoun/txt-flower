require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'YAML'

require_relative '../common_format_helpers'

module Impressions
  # Output file: AlphabeticalIndexTT.txt
  class AlphabeticalIndex
    include ::CommonFormatHelpers

    def initialize(category_csv = './lib/impressions/CompanyCategory.csv')
      @category_rows = CSV.read(category_csv, headers: true)
      @template = YAML.safe_load(File.open('./lib/impressions/impressions.yml'))
      @header_style = @template['alphabetical_index']['header']
      generate_text
    end

    def generate_text
      output = File.open('./lib/impressions/AlphabeticalIndexTT.txt', 'w')
      output << @header_style
      output << alphabet_list
      output.close
    end

    private

    def alphabet_list
      @category_rows.sort_by do |row|
        [row[cat_col_name('base_product')].downcase]
      end
      letters = ('A'..'Z').to_a

      alphabet = Hash[letters.map { |x| [x, []] }]
      numerics = []

      @category_rows.each do |row|
        name = row[cat_col_name('base_product')]
        first_letter = name.initial.upcase
        return numerics.push(name) if first_letter.number?
        return alphabet[first_letter].push(name)
      end

      pp 'SOME CRAZY THING'
      alphabet
    end

    def cat_col_name(property)
      @template['csv_headers']['company_category'][property]
    end
  end
end

class String
  def initial
    self[0, 1]
  end

  def number?
    begin
      true if Float(self)
    rescue StandardError
      false
    end
  end
end
