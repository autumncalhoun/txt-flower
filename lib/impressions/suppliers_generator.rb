require 'pry'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'Phony'
require 'Phone'
require 'YAML'
require 'fileutils'

# puts Diffy::Diff.new('/Users/autumn/src/tagged_text/impressions/2021/test/SuppliersTT.txt', '/Users/autumn/src/tagged_text/impressions/2020/tagged_text/SuppliersTT.t
# xt', source: 'files', context: 5).to_s(:color)

class String
  def initial
    self[0, 1]
  end
  def initial2
    self[0, 2]
  end
end

module Impressions
  class SuppliersGenerator
    attr_accessor :output, :line_break, :tags, :output_location, :header

    def initialize(companies_csv:, branches_csv:, output_location:)
      @output_location = output_location

      template = YAML.safe_load(File.open('./lib/impressions/impressions.yml')).deep_symbolize_keys
      @tags = set_tags_from_yml(template)

      @output = ''
      @line_break = "\n"

      @data = CSV.read(companies_csv, headers: true)
      @branches = CSV.read(branches_csv, headers: true)
      @header = set_header_from_yml(template)
    end

    def generate_text
      supplier_loop
      write_output_to_file
    end

    private

    def write_output_to_file
      FileUtils.mkdir_p output_location unless Dir.exist? output_location
      file = File.open(File.join(output_location, 'SuppliersTT.txt'), 'w')
      file << header
      file << output
      file.close
    end

    def format_phone(number, country)
      pn_string = number ? number.to_s : ''
      unless pn_string.blank?
        if (country == 'United States' || country == 'Canada')
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
      return pn_string
    end

    def address(item)
      street = item['Address'] ? tags[:body] + item['Address'] + line_break : ''
      street2 = item['Address2'] ? tags[:body] + item['Address2'] + line_break : ''
      city = item['City'] || ''
      state = item['State'] || ''
      zip = item['Postal_Code'] || ''
      co = item['Country'] || ''

      if co == 'United States'
        return street + street2 + tags[:body] + city + ', ' + state + ' ' + zip + line_break
      elsif co == 'Canada'
        return street + street2 + tags[:body] + city + ', ' + state + ' ' + zip + ' ' + co + line_break
      else
        return street + street2 + tags[:body] + city + ' ' + co + ' ' + zip + line_break
      end
      return ''
    end

    def city_state_zip(item)
      city = item['BranchCity'] || ''
      state = item['BranchState'] || ''
      co = item['BranchCountry'] || ''
      if co == 'United States'
        return city + ', ' + state
      elsif co == 'Canada'
        return city + ', ' + state + ' ' + co
      else
        return city + ', ' + co
      end
    end

    def phone(item)
      primary = item['Phone'] ? format_phone(item['Phone'], item['Country']) : ''
      tollfree_num = item['TollFree_Phone'] ? format_phone(item['TollFree_Phone'], item['Country']) : ''
      spacer = (!primary.blank? && !tollfree_num.blank?) ? ' | ' : ''
      return tags[:body] + tollfree_num + spacer + primary + line_break
    end

    def supplier_loop
      @data.each do |c|
        #name
        output << tags[:company_name] + c['CompanyName'].to_s + line_break

        #website
        website = c['URL'] ? c['URL'] : ''
        website_formatted = website.sub(%r{^https?\:\/\/}, '').sub(/^www./, '')
        output << tags[:web] + website_formatted + line_break unless website.blank?

        #address
        output << address(c)

        # Phone 1 800 | alt number
        output << phone(c)

        #branches
        matching_branches = @branches.select { |b| b[0] == c[0] }
        matching_branches.each_with_index do |branch, index|
          #branch header
          output << tags[:branches] + 'BRANCHES' + line_break if index == 0

          #branch name
          output << tags[:branch_name] + branch['BranchCompanyName'] + line_break

          #branch location
          output << tags[:body] + city_state_zip(branch) + line_break
        end
      end
    end

    def set_header_from_yml(template)
      find_defs(template)[:header]
    end

    def set_tags_from_yml(template)
      find_defs(template)[:styles]
    end

    def find_defs(template)
      template[:suppliers]
    end
  end
end
