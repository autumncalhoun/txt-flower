require 'pry'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'YAML'
require 'fileutils'

module EFA
  class ProductCategoryIndexGenerator
    attr_accessor :output_dir
    def initialize(csv_location:, output_dir:)
      @output_dir = output_dir
      @data = CSV.read(csv_location, headers: true)
      @styles = { cat: '<ParaStyle:PL-Head1-4>', prod: "<ParaStyle:PL\_Body\_Index-4>" }
      @output = ''
      @line_break = "\n"
      @header =
        "<ASCII-MAC>
<Version:12><FeatureSet:InDesign-Roman><ColorTable:=<Paper:COLOR:CMYK:Process:0,0,0,0><EFA\_Light Blue:COLOR:CMYK:Process:0.6071999669075012,0.23349998891353607,0.21480000019073486,0><Black:COLOR:CMYK:Process:0,0,0,1>>
<DefineKinsokuStyle:Word\_Kinsoku=>
<DefineParaStyle:PL-Head1-4=<Nextstyle:PL-Head1-4><cColor:Paper><cTypeface:77 Bold Condensed><cSize:11.000000><cTracking:100><cCase:All Caps><pLeftIndent:2.000000><cLeading:13.000000><pSpaceBefore:13.500000><pSpaceAfter:4.500000><cFont:Helvetica Neue LT Std><pDesiredWordSpace:0.850000><pMaxWordSpace:1.000000><pDesiredLetterspace:-0.050000><pMinLetterspace:-0.050000><pRuleAboveColor:EFA\_Light Blue><pRuleAboveStroke:15.000000><pRuleAboveTint:100.000000><pRuleAboveOffset:-2.880000><pRuleAboveOn:1><pRuleAboveGapColor:None><pRuleBelowGapColor:None><pDropCapDetail:LeftGlyphEdge><cUnderlineGapColor:None><cStrikeThroughGapColor:None><pShadingColor:Pro Black><pWarichuAlignment:Left><bnColor:None><numFont:\<TextFont\>><rUseOTProGlyph:1><cRubyEdgeSpace:1>>
<DefineParaStyle:PL\_Body\_Index-4=<Nextstyle:PL\_Body\_Index-4><cTypeface:57 Condensed><cSize:11.000000><cAutoPairKern:Optical><cTracking:20><cLeading:13.000000><pHyphenation:0><pTabRuler:154\,Right\,.\,0\,.\;><cFont:Helvetica Neue LT Std><pDesiredWordSpace:0.950000><pMaxWordSpace:1.000000><pMinWordSpace:0.500000><pDesiredLetterspace:-0.100000><pMinLetterspace:-0.150000><pRuleAboveGapColor:None><pRuleBelowGapColor:None><pDropCapDetail:LeftGlyphEdge><cUnderlineGapColor:None><cStrikeThroughGapColor:None><pShadingColor:Pro Black><pWarichuAlignment:Left><bnColor:None><numFont:\<TextFont\>><rUseOTProGlyph:1><cRubyEdgeSpace:1>>\n"
    end

    def generate_text
      cat_loop
      write_output_to_file
    end

    private

    def write_output_to_file
      FileUtils.mkdir_p output_dir unless Dir.exist? output_dir
      file = File.open(File.join(output_dir, 'ProdCatIndexTT.txt'), 'w')
      file << @header
      file << @output
      file.close
    end

    # This is a list of Product Categories. Under each Category are subcategories.
    # be sure to list all subcategories, even if they match the category's name.
    def cat_loop
      # sort by cat, then subcat, then sub subcat
      cat_index = @data

      current_cat = ''
      current_subcat = ''

      cat_index.each do |c|
        # Loop through and write the cat, subcat or subsubcat if it has not already been written (so it is unique)
        cat = c['CategoryPath'].split('->')[0]
        subcat = c['CategoryName'] || ''

        if current_cat != cat
          @output << @styles[:cat] + cat + @line_break
          current_cat = cat
        end

        if current_subcat != subcat
          @output << @styles[:prod] + subcat + "\t" + @line_break
          current_subcat = subcat
        end
      end

      @output
    end
  end
end
