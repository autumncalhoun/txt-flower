require 'pry'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'YAML'
require 'fileutils'

module EFA
  class ProductCategoryListGenerator
    attr_accessor :output_dir
    def initialize(csv_location:, output_dir:)
      @output_dir = output_dir
      @data = CSV.read(csv_location, headers: true)
      @styles = {
        head: '<ParaStyle:PL-Head1-2>',
        head2: '<ParaStyle:PL-Head2-2>',
        company: '<ParaStyle:PL-Body Text-2>',
      }
      @output = ''
      @line_break = "\n"
      @header =
        "<ASCII-MAC>
<Version:12><FeatureSet:InDesign-Roman><ColorTable:=<Paper:COLOR:CMYK:Process:0,0,0,0><EFA\_Light Blue:COLOR:CMYK:Process:0.6071999669075012,0.23349998891353607,0.21480000019073486,0><Black:COLOR:CMYK:Process:0,0,0,1>>
<DefineKinsokuStyle:Word\_Kinsoku=>
<DefineParaStyle:PL-Head1-2=<Nextstyle:PL-Head1-2><cColor:Paper><cTypeface:77 Bold Condensed><cSize:11.000000><cTracking:100><cCase:All Caps><pLeftIndent:2.000000><cLeading:13.000000><pSpaceBefore:13.500000><pSpaceAfter:4.500000><cFont:Helvetica Neue LT Std><pDesiredWordSpace:0.850000><pMaxWordSpace:1.000000><pDesiredLetterspace:-0.050000><pMinLetterspace:-0.050000><pRuleAboveColor:EFA\_Light Blue><pRuleAboveStroke:15.000000><pRuleAboveTint:100.000000><pRuleAboveOffset:-2.880000><pRuleAboveOn:1><pRuleAboveGapColor:None><pRuleBelowGapColor:None><pDropCapDetail:LeftGlyphEdge><cUnderlineGapColor:None><cStrikeThroughGapColor:None><pShadingColor:Pro Black><pWarichuAlignment:Left><bnColor:None><numFont:\<TextFont\>><rUseOTProGlyph:1><cRubyEdgeSpace:1>>
<DefineParaStyle:PL-Body Text-2=<Nextstyle:PL-Body Text-2><cTypeface:57 Condensed><cSize:11.000000><cAutoPairKern:Optical><cTracking:20><cLeading:13.000000><pHyphenation:0><cFont:Helvetica Neue LT Std><pDesiredWordSpace:0.950000><pMaxWordSpace:1.000000><pMinWordSpace:0.500000><pDesiredLetterspace:-0.100000><pMinLetterspace:-0.150000><pRuleAboveGapColor:None><pRuleBelowGapColor:None><pDropCapDetail:LeftGlyphEdge><cUnderlineGapColor:None><cStrikeThroughGapColor:None><pShadingColor:Pro Black><pWarichuAlignment:Left><bnColor:None><numFont:\<TextFont\>><rUseOTProGlyph:1><cRubyEdgeSpace:1>>
<DefineParaStyle:PL-Head2-2=<BasedOn:PL-Body Text-2><Nextstyle:PL-Head2-2><cTypeface:77 Bold Condensed><pLeftIndent:2.000000><pSpaceBefore:6.480000><pSpaceAfter:2.160000><cFont:Helvetica Neue LT Std><pRuleAboveColor:EFA\_Light Blue><pRuleAboveStroke:15.000000><pRuleAboveTint:15.000000><pRuleAboveOffset:-3.600000><pRuleAboveOn:1>>\n"
    end

    def generate_text
      prod_cat_loop
      write_output_to_file
    end

    private

    def write_output_to_file
      FileUtils.mkdir_p output_dir unless Dir.exist? output_dir
      file = File.open(File.join(output_dir, 'ProdCatListTT.txt'), 'w')
      file << @header
      file << @output
      file.close
    end

    def prod_cat_loop
      cat_index = @data # data is already sorted
      current_cat = ''
      current_subcat = ''

      # Loop through the category. If the category only has one subcategory, don't write the subcat.
      # If it has more than one subcategory, write them all.
      # {
      #   'Electronics': {
      #     subcats: []
      #   }
      # }

      category_info = {}
      cat_index.each do |row|
        cat = row['CategoryPath']
        subcat = row['CategoryName'] || ''

        if current_cat != cat
          category_info[cat] = { subcats: [] }
          current_cat = cat
        end

        if current_subcat != subcat
          category_info[cat][:subcats].push(subcat)
          current_subcat = subcat
        end
      end

      cat_index.each do |c|
        # Loop through and write the cat, subcat if it has not already been written (so it is unique)
        cat = c['CategoryPath']
        subcat = c['CategoryName'] || ''
        company = c['CompanyName']

        if current_cat != cat
          @output << @styles[:head] + cat + @line_break
          current_cat = cat
          current_subcat = '' # reset the subcat when the cat changes
        end

        # If there is only one subcategory for this category and it matches the current cat name, don't write the title
        # Otherwise write it, even if it's the same as the current category
        if subcat == cat && category_info[cat][:subcats].length == 1
          pp "Unusual Category/Subcategory: #{cat} - #{subcat}"
        end

        if current_subcat != subcat
          @output << @styles[:head2] + subcat + @line_break
          current_subcat = subcat
        end

        @output << @styles[:company] + company + @line_break
      end
      @output
    end

    # def write_file
    #   output = File.open('2020/ProdCatListTT.txt', 'w')
    #   output << @header
    #   output << @output
    #   output.close
    # end
  end
end
