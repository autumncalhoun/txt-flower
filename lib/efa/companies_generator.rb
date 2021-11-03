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
    attr_accessor :csv_location,
                  :output_dir,
                  :template,
                  :tags,
                  :company_rows,
                  :output

    def initialize(csv_location:, output_dir:)
      @csv_location = csv_location
      @output_dir = output_dir
      @template = YAML.safe_load(File.open('./lib/efa/efa.yml'))
      @tags =
        @template['tagged_text_files'].select! do |file_meta|
          file_meta['tags'] if file_meta['generator'] == 'Companies'
        end
      @company_rows = CSV.read(@csv_location, headers: true)
      @output = ''
      @data = CSV.read(@csv_location, headers: true)
      @styles = {
        co_name: '<ParaStyle:New\_BG-CoName>',
        body: '<ParaStyle:New\_BG-Body Text>'
      }
      @line_break = "\n"
      @header =
        '<ASCII-MAC>
<Version:12><FeatureSet:InDesign-Roman><ColorTable:=<Black:COLOR:CMYK:Process:0,0,0,1><Pro Black:COLOR:CMYK:Process:0.6,0.4,0.4,1>>
<DefineKinsokuStyle:Word\_Kinsoku=>
<DefineCharStyle:Book ital=<Nextstyle:Book ital><KeyboardShortcut:Cmd\+Num 2><cTypeface:Book Italic>>
<DefineParaStyle:New\_BG-CoName=<Nextstyle:New\_BG-CoName><KeyboardShortcut:Shift\+Num 1><cTypeface:77 Bold Condensed><cSize:14.000000><cTracking:10><cLeading:13.000000><pHyphenation:0><pSpaceBefore:10.799999><cFont:Helvetica Neue LT Std><pDesiredWordSpace:0.850000><pMaxWordSpace:1.000000><pDesiredLetterspace:-0.050000><pMinLetterspace:-0.050000><cColorTint:100.000000><pRuleAboveColor:Black><pRuleAboveStroke:0.500000><pRuleAboveTint:75.000000><pRuleAboveOffset:15.840000><pRuleAboveOn:1><pRuleAboveGapColor:None><pRuleBelowGapColor:None><pDropCapDetail:LeftGlyphEdge><cUnderlineGapColor:None><cStrikeThroughGapColor:None><pShadingColor:Pro Black><pWarichuAlignment:Left><bnColor:None><numFont:\<TextFont\>><rUseOTProGlyph:1><cRubyEdgeSpace:1>>
<DefineParaStyle:New\_BG-CoNameNoLine=<BasedOn:New\_BG-CoName><Nextstyle:New\_BG-CoNameNoLine><KeyboardShortcut:Shift\+Num 2><cTypeface:77 Bold Condensed><cSize:14.000000><cFont:Helvetica Neue LT Std><pRuleAboveOn:0>>
<DefineParaStyle:New\_BG-Body Text=<Nextstyle:New\_BG-Body Text><cTypeface:67 Medium Condensed><cSize:11.000000><cAutoPairKern:Optical><cTracking:-5><cLeading:13.000000><pHyphenation:0><cFont:Helvetica Neue LT Std><pDesiredWordSpace:0.950000><pMaxWordSpace:1.000000><pMinWordSpace:0.500000><pDesiredLetterspace:-0.100000><pMinLetterspace:-0.150000><pRuleAboveGapColor:None><pRuleBelowGapColor:None><pDropCapDetail:LeftGlyphEdge><cUnderlineGapColor:None><cStrikeThroughGapColor:None><pShadingColor:Pro Black><pWarichuAlignment:Left><bnColor:None><numFont:\<TextFont\>><rUseOTProGlyph:1><cRubyEdgeSpace:1>>
<DefineParaStyle:NormalParagraphStyle=<Nextstyle:NormalParagraphStyle><cFont:Times><pRuleAboveGapColor:None><pRuleBelowGapColor:None><cUnderlineGapColor:None><cStrikeThroughGapColor:None><pWarichuAlignment:Left><bnColor:None><numFont:\<TextFont\>><rUseOTProGlyph:1><cRubyEdgeSpace:1>>
<DefineParaStyle:New\_SeeOurAd=<BasedOn:NormalParagraphStyle><Nextstyle:New\_SeeOurAd><cTypeface:77 Bold Condensed><cSize:6.500000><cLeading:9.000000><pTabRuler:3\,Right\,.\,0\,\;><cFont:Helvetica Neue LT Std>>' +
          "\n"
    end

    def generate_text
      companies_loop
      FileUtils.mkdir_p output_dir
      file = File.open(File.join(output_dir, 'CompaniesTT.txt'), 'w')
      file << @header
      file << @output
      file.close
    end

    def col_name(property)
      template['csv_headers']['companies'][property]
    end

    def format_phone(number, country)
      pn_string = number ? number.to_s : ''
      return pn_string if pn_string.blank?
      return pn_string if vanity_number(pn_string)

      if (
           country == 'United States' || country == 'Canada' ||
             country.to_s.length < 1
         )
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

    #OPTIONS FOR HEADERS {street: '', street2: '', city: '', state: '', zip: '', co: ''}
    def address(item, headers)
      street =
        if item[headers[:street]]
          @styles[:body] + item[headers[:street]] + @line_break
        else
          ''
        end
      street2 =
        if item[headers[:street2]]
          @styles[:body] + item[headers[:street2]] + @line_break
        else
          ''
        end
      city = item[headers[:city]] || ''
      state = item[headers[:state]] || ''
      zip = item[headers[:zip]] || ''
      co = item[headers[:co]] || ''

      return @styles[:body] + city + ', ' + state + @line_break
    end

    # {primary: '', tollfree: '', co: ''}
    def phone(item, headers)
      primary =
        if item[headers[:primary]]
          format_phone(item[headers[:primary]], item[headers[:co]])
        else
          ''
        end
      tollfree_num =
        if item[headers[:tollfree]]
          format_phone(item[headers[:tollfree]], item[headers[:co]])
        else
          ''
        end
      spacer = (!primary.blank? && !tollfree_num.blank?) ? ', ' : ''
      return @styles[:body] + tollfree_num + spacer + primary + @line_break
    end

    def companies_loop
      companies = @data
      companies.each do |c|
        #name
        output << @styles[:co_name] + c['Company_Name'] + @line_break

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
                co: 'Country'
              }
            )
        end

        # Phone 1 800 | alt number
        if c['Phone'] || c['Toll_Free_Phone']
          output <<
            phone(
              c,
              { primary: 'Phone', tollfree: 'Toll_Free_Phone', co: 'Country' }
            )
        end

        # email
        email = c['Email'] ? @styles[:body] + c['Email'] + @line_break : ''
        output << email

        #website
        website = c['URL'] ? c['URL'] : ''
        website_formatted = website.sub(%r{^https?\:\/\/}, '')
        unless website.blank?
          output << @styles[:body] + website_formatted + @line_break
        end
      end
    end
  end
end
