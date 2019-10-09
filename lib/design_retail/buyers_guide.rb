require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'Phony'
require 'Phone'
require 'YAML'

# design:retail buyer's guide
# Output file: CompanyTT.txt
# CSV column headers (Companies.csv): CompanyID, Company_Name, City, State, Country, Phone, Email_Address, URL
# CSV column headers (CompanyCategory.csv): CompanyID, CompanyName, CategoryName
class DesignRetail
  attr_accessor :template, :company_rows, :category_rows

  def initialize(company_csv = './lib/design_retail/Companies.csv', category_csv = './lib/design_retail/CompanyCategory.csv')
    @company_rows = CSV.read(company_csv, headers: true)
    @category_rows = CSV.read(category_csv, headers: true)
    @template = YAML.safe_load(File.open('./lib/design_retail/buyers_guide.yml'))
    @header_style = @template['header']
    generate_text
  end

  def generate_text
    output = File.open('./lib/design_retail/CompanyTT.txt', 'w')
    output << @header_style
    output << company_list
    output.close
  end

  private

  def line_break
    "\n"
  end

  def company_list
    companies = @company_rows.map do |row|
      company = Company.new(
        name: row.field(col_name('name')),
        city: row.field(col_name('city')),
        state: row.field(col_name('state')),
        country: row.field(col_name('country')),
        phone: row.field(col_name('phone')),
        tollfree: row.field(col_name('tollfree')),
        email: row.field(col_name('email')),
        url: row.field(col_name('url'))
      ).to_s
      categories = ProductCategories.new(
        company_id: row.field(col_name('id')),
        category_rows: @category_rows
      ).to_s
      company + line_break + categories
    end
    companies.join(line_break)
  end

  def col_name(property)
    @template['csv_headers']['companies'][property]
  end
end

# <ParaStyle:BG-CoName>1000LED Inc.
# <ParaStyle:BG-Body Text>Dallas, TX
# <ParaStyle:BG-Body Text>(877) 340-1700
# <ParaStyle:BG-Body Text>info@1000led.com
# <ParaStyle:BG-Body Text>1000led.com
class Company
  attr_accessor :name, :city, :state, :country, :phone, :tollfree, :email, :url, :template

  def initialize(name:, city:, state:, country:, phone:, tollfree:, email:, url:)
    @name = name
    @city = city
    @state = state
    @country = country
    @phone = phone
    @tollfree = tollfree
    @email = email
    @url = url
    @template = YAML.safe_load(File.open('./lib/design_retail/buyers_guide.yml'))
  end

  def to_s
    [
      formatted_name,
      formatted_address,
      formatted_phone,
      formatted_email,
      formatted_url
    ].compact.join(line_break)
  end

  private

  def formatted_name
    style = @template['styles']['company_name']
    style + name
  end

  def formatted_address
    style = @template['styles']['body']
    address = style + @city
    address << (', ' + @state) if @state && @state != 'NULL' && @state != 'N/A'
    address << (', ' + @country) if @country != 'United States'
    address
  end

  def formatted_phone
    return unless @phone || @tollfree
    style = @template['styles']['body']

    number2 = format_phone(@tollfree, @country)

    phone_string = style + format_phone(@phone, @country)
    phone_string << ', ' + number2 unless number2.blank?
    phone_string
  end

  def formatted_email
    return unless @email
    style = @template['styles']['body']
    style + @email
  end

  def formatted_url
    return unless @url
    style = @template['styles']['body']
    url_formatted = @url.sub(/^https?\:\/\//, '').sub(/^www./, '')
    style + url_formatted
  end

  def line_break
    "\n"
  end

  def format_phone(number, country)
    pn_string = number.to_s
    return pn_string if pn_string.blank?
    return pn_string if vanity_number(pn_string)

    domestic_countries = ['United States', 'Canada']
    if domestic_countries.include?(country)
      pn_string = pn_string.prepend('+1') if pn_string.initial != '1'

      return pn_string unless Phoner::Phone.valid? pn_string

      pn = Phoner::Phone.parse(pn_string, country_code: '1')
      pn_formatted = pn.format('(%a) %f-%l %x')
      return pn_formatted.strip
    else
      return pn_string unless Phony.plausible?(pn_string)
      pn = Phony.normalize(pn_string)
      pn_formatted = Phony.format(pn)
      return pn_formatted
    end
  end

  def vanity_number(number)
    return number.count("a-zA-Z") > 0
  end
end

# <ParaStyle:POP chart\:Product Category Text>PRODUCT CATEGORIES: Warehousing, fulfillment, logistics management and installation services
class ProductCategories
  attr_accessor :category_rows, :template
  def initialize(company_id:, category_rows:)
    @company_id = company_id
    @category_rows = category_rows
    @template = YAML.safe_load(File.open('./lib/design_retail/buyers_guide.yml'))
  end

  def to_s
    style = @template['styles']['product_category']
    style + 'PRODUCT CATEGORIES: ' + filter_categories_and_select_names.join(', ')
  end

  def filter_categories_and_select_names
    id_header = @template['csv_headers']['company_category']['company_id']
    cat_name = @template['csv_headers']['company_category']['category_name']

    @category_rows.each_with_object([]) do |row, filtered|
      filtered << row[cat_name] if row[id_header] == @company_id
    end
  end
end

class String
  def initial
    self[0, 1]
  end
end
