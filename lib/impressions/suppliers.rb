require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'YAML'

require_relative '../common_format_helpers'

# Impressions
module Impressions
  # Output file: SuppliersTT.txt
  # CSV column headers (Companies.csv): CompanyID, Company_Name, Company_Type, Adress, Address2, City, State, Postal_Code, Country, Phone, TollFree_Phone, URL
  # CSV column headers (CompanyCategory.csv): CompanyID, CompanyName, CategoryName
  class Suppliers
    include ::CommonFormatHelpers

    def initialize(company_csv = './lib/impressions/Companies.csv', branch_csv = './lib/impressions/Branches.csv')
      @company_rows = CSV.read(company_csv, headers: true)
      @branch_rows = CSV.read(branch_csv, headers: true)
      @template = YAML.safe_load(File.open('./lib/impressions/impressions.yml'))
      @header_style = @template['suppliers']['header']
      generate_text
    end

    def generate_text
      output = File.open('./lib/impressions/SuppliersTT.txt', 'w')
      output << @header_style
      output << company_list
      output.close
    end

    private_methods

    def company_list
      companies = @company_rows.map do |row|
        company = Company.new(
          name: row.field(col_name('name')),
          url: row.field(col_name('url')),
          address: row.field(col_name('address')),
          address2: row.field(col_name('address2')),
          city: row.field(col_name('city')),
          state: row.field(col_name('state')),
          country: row.field(col_name('country')),
          postal_code: row.field(col_name('postal_code')),
          phone: row.field(col_name('phone')),
          tollfree: row.field(col_name('tollfree'))
        ).to_s
        branches = Branches.new(
          company_id: row.field(col_name('id')),
          branch_rows: @branch_rows
        ).to_s
        company + branches
      end
      companies.join(line_break)
    end

    def col_name(property)
      @template['suppliers']['csv_headers']['companies'][property]
    end
  end

  # <ParaStyle:Plain name>A-B Emblem
  # <ParaStyle:www>abemblem.com
  # <ParaStyle:Plain listing>P.O. Box 695, Ste 115
  # <ParaStyle:Plain listing>Weaverville, NC 28787-0695
  # <ParaStyle:Plain listing>(800) 438-4285 | (800) 438-4285
  class Company
    attr_accessor :name, :template
    include ::CommonFormatHelpers

    def initialize(name:, url:, address:, address2:, city:, state:, country:, postal_code:, phone:, tollfree:)
      @name = name
      @url = url
      @address = address
      @address2 = address2
      @city = city
      @state = state
      @country = country
      @postal = postal_code
      @phone = phone
      @tollfree = tollfree
      @template = YAML.safe_load(File.open('./lib/impressions/impressions.yml'))
    end

    def to_s
      [
        formatted_name,
        formatted_url,
        formatted_address,
        formatted_phone
      ].compact.join(line_break)
    end

    private

    def formatted_name
      style = @template['suppliers']['styles']['company_name']
      style + name
    end

    def formatted_url
      return unless @url
      style = @template['suppliers']['styles']['web']
      url_formatted = @url.sub(/^https?\:\/\//, '').sub(/^www./, '')
      style + url_formatted
    end

    def formatted_address
      street_address + line_break + city_state_country
    end

    # tollfree first
    def formatted_phone
      return unless @phone || @tollfree
      style = @template['suppliers']['styles']['body']

      tollfree = format_phone(@tollfree, @country)

      phone_string = style + tollfree
      phone_string << ' | ' unless tollfree.blank?
      phone_string << format_phone(@phone, @country)
      phone_string
    end

    def street_address
      style = @template['suppliers']['styles']['body']
      address = style + @address
      address << ', ' + @address2 if @address2
      address
    end

    def city_state_country
      style = @template['suppliers']['styles']['body']

      address = style + @city
      address << (', ' + @state) if @state && @state != 'NULL' && @state != 'N/A'
      address << (', ' + @country) if @country != 'United States'
      address << (' ' + @postal) if @postal
      address
    end
  end

  # <ParaStyle:branch office>BRANCHES
  # <ParaStyle:Plain name branch>Abel warehouse
  # <ParaStyle:Plain listing>Memphis, TN
  class Branches
    include ::CommonFormatHelpers

    def initialize(company_id:, branch_rows:)
      @company_id = company_id
      @branch_rows = branch_rows
      @template = YAML.safe_load(File.open('./lib/impressions/impressions.yml'))
    end

    def to_s
      style = @template['suppliers']['styles']['branches']
      branches = filter_branches
      return '' if branches.empty?
      header = line_break + style + 'BRANCHES' + line_break
      header + filter_branches.join(line_break)
    end

    def filter_branches
      id_header = @template['suppliers']['csv_headers']['branches']['company_id']
      branch_name = @template['suppliers']['csv_headers']['branches']['name']
      branch_city = @template['suppliers']['csv_headers']['branches']['city']
      branch_state = @template['suppliers']['csv_headers']['branches']['state']
      branch_country = @template['suppliers']['csv_headers']['branches']['country']

      @branch_rows.each_with_object([]) do |row, filtered|
        next unless row[id_header] == @company_id
        address = branch_address(row[branch_city], row[branch_state], row[branch_country])
        branch_string = branch_name(row[branch_name]) + line_break + address
        filtered << branch_string
      end
    end

    def branch_name(name)
      name_style = @template['suppliers']['styles']['branch_name']
      name_style + name
    end

    def branch_address(city, state, country)
      body_style = @template['suppliers']['styles']['body']
      string = body_style + city
      string << ', ' + state if state
      string << ' ' + country if country != 'United States'
      string
    end
  end
end

class String
  def initial
    self[0, 1]
  end
end
