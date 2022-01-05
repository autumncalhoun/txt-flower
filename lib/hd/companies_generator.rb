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

module HD
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

      template = YAML.safe_load(File.open('./lib/hd/hd.yml')).deep_symbolize_keys
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
      unless pn_string.blank?
        if (country == 'United States' || country == 'Canada' || country.to_s.length < 1)
          pn_string = pn_string.prepend('+1') if (pn_string.initial != '1')

          if (Phoner::Phone.valid? pn_string)
            pn = Phoner::Phone.parse(pn_string, country_code: '1')
            pn_formatted = pn.format('%a.%f.%l %x')
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
      return pn_string
    end

    #OPTIONS FOR HEADERS {street: '', street2: '', city: '', state: '', zip: '', co: ''}
    def address(item, headers)
      city = item[headers[:city]] || ''
      state = item[headers[:state]] || item[headers[:co]] || ''
      return tags[:body] + city + ', ' + state + line_break
    end

    # {primary: '', tollfree: '', co: ''}
    def phone(item, headers)
      # the country is in the state field
      country =
        if item[headers[:state]]&.length && item[headers[:state]]&.length > 2
          item[headers[:state]].split(', ').last
        else
          'United States'
        end
      primary = item[headers[:primary]] ? format_phone(item[headers[:primary]], country) : ''
      tollfree_num = item[headers[:tollfree]] ? format_phone(item[headers[:tollfree]], country) : ''
      spacer = (!primary.blank? && !tollfree_num.blank?) ? ', ' : ''
      return tags[:body] + tollfree_num + spacer + primary + line_break
    end

    def companies_loop
      companies =
        company_rows.sort_by do |c|
          company_name = c['Company_Name'].downcase
          company_name = company_name.start_with?('the ') ? company_name.split('the ').last : company_name
          company_name
        end

      companies.each do |c|
        #name
        output << tags[:company_name] + c['Company_Name'] + line_break

        #address
        if c['City']
          output <<
            address(
              c,
              {
                street: 'Address',
                street2: 'Address2',
                city: 'City',
                state: 'State',
                zip: 'Postal_Code',
                co: 'Country',
              },
            )
        end

        # Phone 1 800 | alt number
        if c['Phone'] || c['TollFree_Phone']
          output << phone(c, { primary: 'Phone', tollfree: 'TollFree_Phone', co: 'Country', state: 'State' })
        end

        # email
        email = c['Email'] ? tags[:body] + c['Email'] + line_break : ''
        output << email

        #website
        website = c['URL'] ? c['URL'] : ''
        website_formatted = website.sub(%r{^https?\:\/\/}, '').sub(/^www./, '')
        output << tags[:body] + website_formatted + line_break unless website.blank?
      end
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
