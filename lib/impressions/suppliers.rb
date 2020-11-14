require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'YAML'
require 'fileutils'

require_relative '../common_format_helpers'

module Impressions
  # Output file: SuppliersTT.txt
  # CSV column headers (Companies.csv): CompanyID, Company_Name, Company_Type, Adress, Address2, City, State, Postal_Code, Country, Phone, TollFree_Phone, URL
  # CSV column headers (CompanyCategory.csv): CompanyID, CompanyName, CategoryName
  class Suppliers
    include ::CommonFormatHelpers

    def initialize(company_csv: './lib/impressions/Companies.csv', branch_csv: './lib/impressions/Branches.csv', output_destination:)
      @company_rows = CSV.read(company_csv, headers: true)
      @branch_rows = CSV.read(branch_csv, headers: true)
      @template = YAML.safe_load(File.open('./lib/impressions/impressions.yml'))
      @header_style = @template['suppliers']['header']
      @line_break = "\n"
      @output = ""
      @destination = "#{output_destination}/SuppliersTT.txt"
      generate_text
    end

    def generate_text
      dirname = File.dirname(@destination)
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end
      output = File.open(@destination, 'w')
      output << @header_style
      supplier_loop
      output << @output
      output.close
    end

    private
    # OLD STUFF
    def format_phone(number, country)
      pn_string = number ? number.to_s : ''
      unless pn_string.blank?
        if ( country == 'United States' || country == 'Canada' )
          if (pn_string.initial != '1')
            pn_string = pn_string.prepend("+1")
          end

          if ( Phoner::Phone.valid? pn_string )
            pn = Phoner::Phone.parse(pn_string, :country_code => '1')
            pn_formatted = pn.format("(%a) %f-%l %x")
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
      street = item[3] ? (@template['suppliers']['styles']['body'] + item[3].strip + @line_break) : ''
      street2 = item[4] ? (@template['suppliers']['styles']['body'] + item[4].strip + @line_break) : ''
      city = item[5] || ''
      state = item[6] || ''
      zip = item[7] || ''
      co = item[8] || ''

      combined_street = (street + street2)

      if co == "United States"
        return combined_street + @template['suppliers']['styles']['body'] + city + ', ' + state + ' ' + zip + @line_break
      elsif co == "Canada"
        return combined_street + @template['suppliers']['styles']['body'] + city + ', ' + state + ' ' + zip + ' ' + co + @line_break
      else
        return combined_street + @template['suppliers']['styles']['body'] + city + ' ' + co + ' ' + zip + @line_break
      end
    end

    def city_state_zip(item)
      city = item[2] || ''
      state = item[3] || ''
      co = item[4] || ''
      if co == 'United States'
        return city + ', ' + state
      elsif co == 'Canada'
        return city + ', ' + state + ' ' + co
      else
        return city + ', ' + co
      end
    end

    def phone(item)
      primary = item[10] ? format_phone(item[10], item[8]) : ''
      tollfree_num = item[11] ? format_phone(item[11], item[8]) : ''
      spacer = (!primary.blank? && !tollfree_num.blank?) ? ' | ': ''
      return @template['suppliers']['styles']['body'] + tollfree_num + spacer + primary + @line_break
    end

    def supplier_loop
      @company_rows.each do |c|
        #name
        @output << @template['suppliers']['styles']['company_name'] + c[1] + @line_break
        #website
        website = c[9] ? c[9] : ''
        website_formatted = website.sub(/^https?\:\/\//, '').sub(/^www./,'')
        unless website.blank?
          @output << @template['suppliers']['styles']['web'] + website_formatted + @line_break
        end
        #address
        @output << address(c)

        # Phone 1 800 | alt number
        @output << phone(c)

        #branches
        matching_branches = @branch_rows.select {|b| b[0] == c[0]}
        matching_branches.each_with_index do |branch, index|
          #branch header
          if index == 0
            @output << @template['suppliers']['styles']['branches']  + 'BRANCHES' + @line_break
          end
          #branch name
          @output << @template['suppliers']['styles']['branch_name'] + branch[1] + @line_break
          #branch location
          @output << @template['suppliers']['styles']['body'] + city_state_zip(branch) + @line_break
        end
      end
    end
  end
end

class String
  def initial
    self[0, 1]
  end
end
