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
    attr_accessor :csv_location, :output_dir, :template, :tags, :company_rows, :output

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
      @styles = { co_name: '<pstyle:BG-CoNameNoLine>', body: '<pstyle:BG-Body Text>' }
      @line_break = "\n"
      @header =
        '<ASCII-MAC>
<vsn:17><fset:InDesign-Roman><ctable:=<Black:COLOR:CMYK:Process:0,0,0,1><Word\_R32\_G29\_B30:COLOR:RGB:Process:0.12549019607843137,0.11372549019607843,0.11764705882352941>>
<dks:kHardKinsokuName=<bft:\!,\),\,,.,\:,\;,\?,\],\},<0x00A2>,<0x2014>,<0x2019>,<0x201D>,<0x2030>,<0x2103>,<0x2109>,<0x3001>,<0x3002>,<0x3005>,<0x3009>,<0x300B>,<0x300D>,<0x300F>,<0x3011>,<0x3015>,<0x301F>,<0x3041>,<0x3043>,<0x3045>,<0x3047>,<0x3049>,<0x3063>,<0x3083>,<0x3085>,<0x3087>,<0x308E>,<0x309B>,<0x309C>,<0x309D>,<0x309E>,<0x30A1>,<0x30A3>,<0x30A5>,<0x30A7>,<0x30A9>,<0x30C3>,<0x30E3>,<0x30E5>,<0x30E7>,<0x30EE>,<0x30F5>,<0x30F6>,<0x30FB>,<0x30FC>,<0x30FD>,<0x30FE>,<0xFF01>,<0xFF05>,<0xFF09>,<0xFF0C>,<0xFF0E>,<0xFF1A>,<0xFF1B>,<0xFF1F>,<0xFF3D>,<0xFF5D>><aft:\(,\[,\{,<0x00A3>,<0x00A7>,<0x2018>,<0x201C>,<0x3008>,<0x300A>,<0x300C>,<0x300E>,<0x3010>,<0x3012>,<0x3014>,<0x301D>,<0xFF03>,<0xFF04>,<0xFF08>,<0xFF20>,<0xFF3B>,<0xFF5B>,<0xFFE5>><htb:<0x3001>,<0x3002>,<0xFF0C>,<0xFF0E>><nspt:<0x2014>,<0x2025>,<0x2026>>>
<dps:BG-CoName=<Nextstyle:BG-CoName><ct:Bold><cs:14.000000><ctk:10><cl:13.000000><ph:0><psb:10.799999><cf:Bebas Neue Pro><pdws:0.850000><pmaws:1.000000><pdl:-0.050000><pminl:-0.050000><cct:100.000000><prac:Black><pras:0.500000><prat:75.000000><prao:15.840000><praon:1><pshadc:Pro Black><pshadt:-1.000000><pideosp:0><pbcorradTL:1.000000><pbcorradTR:1.000000><pbcorradBL:1.000000><pbcorradBR:1.000000><pscorradTL:1.000000><pscorradTR:1.000000><pscorradBL:1.000000><pscorradBR:1.000000><cdvpos:4>>
<dps:BG-CoNameNoLine=<BasedOn:BG-CoName><Nextstyle:BG-CoNameNoLine><KeyboardShortcut:Shift\+Num 2><praon:0>>
<dps:BG-Body Text=<Nextstyle:BG-Body Text><ct:Regular ><cs:11.000000><capk:Optical><cl:13.000000><ph:0><cf:Bebas Neue Pro><pdws:0.950000><pmaws:1.000000><pmiws:0.500000><pdl:-0.100000><pminl:-0.150000><pshadc:Pro Black><pshadt:-1.000000><pideosp:0><pbcorradTL:1.000000><pbcorradTR:1.000000><pbcorradBL:1.000000><pbcorradBR:1.000000><pscorradTL:1.000000><pscorradTR:1.000000><pscorradBL:1.000000><pscorradBR:1.000000><cdvpos:4>>
<dps:NormalParagraphStyle=<Nextstyle:NormalParagraphStyle><pdws:0.850000><pmaws:1.000000><pdl:-0.050000><pminl:-0.050000><pshadc:Pro Black><pshadt:-1.000000><pideosp:0><pbcorradTL:1.000000><pbcorradTR:1.000000><pbcorradBL:1.000000><pbcorradBR:1.000000><pscorradTL:1.000000><pscorradTR:1.000000><pscorradBL:1.000000><pscorradBR:1.000000><cdvpos:4>>
<dps:New\_SeeOurAd=<BasedOn:NormalParagraphStyle><Nextstyle:New\_SeeOurAd><ct:Bold><cs:9.000000><cl:11.000000><ptr:3\,Right\,.\,0\,\;><cf:Bebas Neue Pro>>
<dps:PhotoCredit=<Nextstyle:PhotoCredit><ct:Regular ><cs:6.000000><ctk:10><ccase:All Caps><phll:0><palp:1.000000><cl:6.000000><cf:Bebas Neue Pro><pmaws:2.000000><pmiws:0.500000><pmaxl:0.250000><pkfnl:1><pknl:1><prac:Black><prat:100.000000><prbc:Black><prbt:100.000000><pswa:Left><pragc:None><prbgc:None><pdcdetail:><cugc:None><cstrikegc:None><pshadc:EFA\_Dark Brown><pshadt:-1.000000><pwa:Left><pideosp:0><pbcorradTL:1.000000><pbcorradTR:1.000000><pbcorradBL:1.000000><pbcorradBR:1.000000><pscorradTL:1.000000><pscorradTR:1.000000><pscorradBL:1.000000><pscorradBR:1.000000><cdvpos:4><ruotpg:0><cres:0>>
<dps:BG-Co Description=<BasedOn:BG-Body Text><Nextstyle:BG-Co Description><ct:Book><cs:9.000000><cl:10.000000><psb:4.500000><cf:Acta><cotfcalt:0>>' +
          "\n"
    end

    def generate_text
      companies_loop

      FileUtils.mkdir_p output_dir unless Dir.exist? output_dir
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

    #OPTIONS FOR HEADERS {street: '', street2: '', city: '', state: '', zip: '', co: ''}
    def address(item, headers)
      street = item[headers[:street]] ? @styles[:body] + item[headers[:street]] + @line_break : ''
      street2 = item[headers[:street2]] ? @styles[:body] + item[headers[:street2]] + @line_break : ''
      city = item[headers[:city]] || ''
      state = item[headers[:state]] || ''
      zip = item[headers[:zip]] || ''
      co = item[headers[:co]] || ''

      return @styles[:body] + city + ', ' + state + @line_break
    end

    # {primary: '', tollfree: '', co: ''}
    def phone(item, headers)
      primary = item[headers[:primary]] ? format_phone(item[headers[:primary]], item[headers[:co]]) : ''
      tollfree_num = item[headers[:tollfree]] ? format_phone(item[headers[:tollfree]], item[headers[:co]]) : ''
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
                co: 'Country',
              },
            )
        end

        # Phone 1 800 | alt number
        if c['Phone'] || c['Toll_Free_Phone']
          output << phone(c, { primary: 'Phone', tollfree: 'Toll_Free_Phone', co: 'Country' })
        end

        # email
        email = c['Email'] ? @styles[:body] + c['Email'] + @line_break : ''
        output << email

        #website
        website = c['URL'] ? c['URL'] : ''
        website_formatted = website.sub(%r{^https?\:\/\/}, '')
        output << @styles[:body] + website_formatted + @line_break unless website.blank?
      end
    end
  end
end
