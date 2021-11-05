require 'pry'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'Phony'
require 'Phone'
require 'YAML'
require 'fileutils'

# TODO: NOT CORRECT

module Impressions
  class CrossReferenceGenerator
    attr_accessor :output_location
    def initialize(company_category_csv:, companies_csv:, output_location:)
      @output_location = output_location

      @data = CSV.read(company_category_csv, headers: true)
      @companies = CSV.read(companies_csv, headers: true)

      @styles = { prod: '<ParaStyle:Product>', subprod: '<ParaStyle:SubProduct>', company: '<ParaStyle:Company>' }
      @output = ''
      @line_break = "\n"
      @header =
        "<ASCII-MAC>
<Version:11.4><FeatureSet:InDesign-Roman><ColorTable:=<Black:COLOR:CMYK:Process:0,0,0,1><Nielsen Gray:COLOR:CMYK:Process:0.48,0.35,0.3,0.16>>
<DefineParaStyle:Product=<cTypeface:Bold><cSize:10.000000><cHorizontalScale:0.950000><cTracking:30><cBaselineShift:7.000000><cCase:All Caps><pHyphenationLadderLimit:0><cLeading:11.000000><pHyphenation:0><pHyphenateCapitals:0><pHyphenationZone:0.000000><pSpaceBefore:22.500000><cFont:Circular Std><pKeepParaTogether:1><pKeepWithNext:1><pKeepLines:1><pRuleAboveColor:Black><pRuleAboveStroke:20.000000><pRuleAboveTint:100.000000><pRuleAboveOffset:1.620000><pRuleBelowColor:Black><pRuleBelowStroke:3.000000><pRuleBelowOffset:-4.500000><pRuleBelowOn:1><pRuleAboveStrokeType:ThinThin><pRuleAboveGapColor:Apparel Blanks><pRuleAboveGapTint:100.000000><pTextAlignment:Center><pRuleAboveKeepInFrame:1>>
<DefineParaStyle:Company=<cSize:7.000000><pHyphenationLadderLimit:0><pLeftIndent:7.199999><pFirstLineIndent:-7.200000><cLeading:9.000000><pHyphenation:0><pHyphenateCapitals:0><pHyphenationZone:0.000000><pTabRuler:89\,Left\,.\,0\,\;108\,Left\,.\,0\,\;163.0500030517578\,Right\,.\,0\,\;><cFont:Adobe Caslon Pro>>
<DefineParaStyle:SubProduct=<cTypeface:Bold><cSize:8.000000><cHorizontalScale:0.930000><cCase:All Caps><pHyphenationLadderLimit:0><cLeading:8.199999><pHyphenation:0><pHyphenateCapitals:0><pHyphenationZone:0.000000><pSpaceBefore:8.640000><pSpaceAfter:0.504000><pTabRuler:89\,Left\,.\,0\,\;108\,Left\,.\,0\,\;163.0500030517578\,Right\,.\,0\,\;><cFont:Circular Std>>\n"
    end

    def generate_text
      cat_loop
      write_output_to_file
    end

    private

    def write_output_to_file
      FileUtils.mkdir_p output_location unless Dir.exist? output_location
      file = File.open(File.join(output_location, 'CrossReferenceTT.txt'), 'w')
      file << @header
      file << @output
      file.close
    end

    def format_phone(number, country)
      pn_string = number ? number.to_s : ''
      unless pn_string.blank?
        if (country == 'United States' || country == 'Canada')
          pn_string = pn_string.prepend('+1') if (pn_string.initial != '1' && pn_string.initial2 != '+1')
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

    def phone(item)
      tollfree_copy = item['TollFree_Phone'] || ''
      primary_copy = item['Phone'] || ''

      if !tollfree_copy.blank?
        tollfree_num = format_phone(tollfree_copy, item['Country'])
        return tollfree_num
      else
        primary = format_phone(primary_copy, item['Country'])
        return primary
      end
    end

    def get_company(cat)
      company = @companies.select { |co| co['Id'] == cat['Id'] }

      return '' unless company[0]
      state = company[0]['State'] || ''
      co_name = company[0]['Company_Name'] || ''
      phone_num = phone(company[0])

      @styles[:company] + co_name + "\t" + state + "\t" + phone_num + @line_break
    end

    def cat_loop
      # sort by cat, then subcat, then sub subcat
      # @data.each do |row|
      #   puts "BLANK" + row[0] if row[1].blank?
      # end
      cat_index =
        @data.sort_by { |d| [d['CategoryName'], d['Product'], d['Subproduct'].to_s, d['CompanyName'].to_s.downcase] }

      current_cat = ''
      current_prod = ''
      current_subprod = ''

      cat_index.each do |c|
        # Loop through and write the cat, subcat or subsubcat if it has not already been written (so it is unique)
        cat = c['CategoryName']
        prod = c['Product'] || ''
        subprod = c['Subproduct'] || ''
        listing = c['Listing']

        if current_cat != cat
          @output << 'CATEGORY ' + cat + @line_break
          current_cat = cat
        end

        if current_prod != prod
          @output << @styles[:prod] + prod + @line_break
          current_prod = prod
        end

        @output << get_company(c) if prod == listing

        if !subprod.blank? && current_subprod != subprod
          @output << @styles[:subprod] + subprod + @line_break

          current_subprod = subprod
        end

        @output << get_company(c) if subprod == listing
      end

      return @output
    end
  end
end
