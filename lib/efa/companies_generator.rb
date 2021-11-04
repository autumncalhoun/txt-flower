require 'pry'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'Phony'
require 'Phone'
require 'YAML'
require 'fileutils'

class String
  def initial
    self[0, 1]
  end
  def initial2
    self[0, 2]
  end
end

module EFA
  class CompaniesGenerator
    attr_accessor :output_location,
                  :csv_location,
                  :tagged_text_file_name,
                  :csv_file_name,
                  :tags,
                  :csv_headers,
                  :company_rows,
                  :output,
                  :line_break

    def initialize(csv_location:, output_location:, tagged_text_file_name:, csv_file_name:)
      @output_location = output_location
      @csv_location = csv_location
      @csv_file_name = csv_file_name
      @tagged_text_file_name = tagged_text_file_name

      template = YAML.safe_load(File.open('./lib/efa/efa.yml')).deep_symbolize_keys
      @tags = set_tags_from_yml(template)
      @csv_headers = set_headers_from_yml(template)
      @company_rows = CSV.read("#{csv_location}/#{csv_file_name}.csv", headers: true)
      @output = ''
      @line_break = "\n"
    end

    def generate_text
      companies_loop
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

    def format_phone(number, country)
      pn_string = number ? number.to_s : ''
      return pn_string if pn_string.blank?
      return pn_string if vanity_number(pn_string)

      if (country == 'United States' || country == 'Canada' || country.to_s.length < 1)
        pn_string = pn_string.prepend('+1') if (pn_string.initial != '1')

        if (Phoner::Phone.valid? pn_string)
          pn = Phoner::Phone.parse(pn_string, country_code: '1')
          pn_formatted = pn.format('(%a) %f-%l %x')
          return pn_formatted.strip
        else
          return pn_string
        end
      else
        if Phony.plausible?(pn_string)
          pn = Phony.normalize(pn_string)
          pn_formatted = Phony.format(pn)
          return pn_formatted
        else
          return pn_string
        end
      end
    end

    def vanity_number(number)
      number.count('a-zA-Z') > 0
    end

    def address(item)
      city = item[city_field] || ''
      state = item[state_field] || ''

      return tags[:body] + city + ', ' + state + line_break
    end

    # {primary: '', tollfree: '', co: ''}
    def phone(item, headers)
      primary = item[headers[:primary]] ? format_phone(item[headers[:primary]], nil) : ''
      tollfree_num = item[headers[:tollfree]] ? format_phone(item[headers[:tollfree]], nil) : ''
      spacer = (!primary.blank? && !tollfree_num.blank?) ? ', ' : ''
      return tags[:body] + tollfree_num + spacer + primary + line_break
    end

    def companies_loop
      company_rows.each do |c|
        #name
        output << tags[:company_name] + c[name_field] + line_break

        #address
        output << address(c) if c[city_field]

        # Phone 1 800 | alt number
        output << phone(c, { primary: phone_field, tollfree: tollfree_field }) if c[phone_field] || c[tollfree_field]

        # email
        output << tags[:body] + c[email_field] + line_break if c[email_field]

        # website
        website = c[url_field] || ''
        website_formatted = website.sub(%r{^https?\:\/\/}, '').sub(/www./, '')
        output << tags[:body] + website_formatted + line_break unless website.blank?
      end
    end

    def url_field
      csv_headers[:url]
    end

    def city_field
      csv_headers[:city]
    end

    def state_field
      csv_headers[:state]
    end

    def name_field
      csv_headers[:name]
    end

    def phone_field
      csv_headers[:phone]
    end

    def tollfree_field
      csv_headers[:tollfree]
    end

    def email_field
      csv_headers[:email]
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
