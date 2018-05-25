require_relative 'format_address'

# Defines entity specific tagging
class EFA < Flower
  # define your allowed files and create a method for tagging each
  TYPES = %w[companies prod_cat_index prod_cat_list].freeze

  # File specific tagging definitions
  def companies
    @styles = {
      co_name: '<ParaStyle:New\_BG-CoName>',
      body: '<ParaStyle:New\_BG-Body Text>'
    }
    text = companies_header_text
    @data.each do |row|
      text << company_name(row['Company_Name'])
      text << FormatAddress.new(row, @styles[:body]).return_string
    end
    @output = text
  end

  def prod_cat_index
    text = ''
    @data.each do |row|
      text << row['Email']
      text << @line_break
    end
    @output = text
  end

  def prod_cat_list
    text = ''
    @data.each do |row|
      text << row['URL']
      text << @line_break
    end
    @output = text
  end

  def companies_header_text
    return '<ASCII-MAC>
<Version:12><FeatureSet:InDesign-Roman><ColorTable:=<Black:COLOR:CMYK:Process:0,0,0,1><Pro Black:COLOR:CMYK:Process:0.6,0.4,0.4,1>>
<DefineKinsokuStyle:Word\_Kinsoku=>
<DefineCharStyle:Book ital=<Nextstyle:Book ital><KeyboardShortcut:Cmd\+Num 2><cTypeface:Book Italic>>
<DefineParaStyle:New\_BG-CoName=<Nextstyle:New\_BG-CoName><KeyboardShortcut:Shift\+Num 1><cTypeface:77 Bold Condensed><cSize:14.000000><cTracking:10><cLeading:13.000000><pHyphenation:0><pSpaceBefore:10.799999><cFont:Helvetica Neue LT Std><pDesiredWordSpace:0.850000><pMaxWordSpace:1.000000><pDesiredLetterspace:-0.050000><pMinLetterspace:-0.050000><cColorTint:100.000000><pRuleAboveColor:Black><pRuleAboveStroke:0.500000><pRuleAboveTint:75.000000><pRuleAboveOffset:15.840000><pRuleAboveOn:1><pRuleAboveGapColor:None><pRuleBelowGapColor:None><pDropCapDetail:LeftGlyphEdge><cUnderlineGapColor:None><cStrikeThroughGapColor:None><pShadingColor:Pro Black><pWarichuAlignment:Left><bnColor:None><numFont:\<TextFont\>><rUseOTProGlyph:1><cRubyEdgeSpace:1>>
<DefineParaStyle:New\_BG-CoNameNoLine=<BasedOn:New\_BG-CoName><Nextstyle:New\_BG-CoNameNoLine><KeyboardShortcut:Shift\+Num 2><cTypeface:77 Bold Condensed><cSize:14.000000><cFont:Helvetica Neue LT Std><pRuleAboveOn:0>>
<DefineParaStyle:New\_BG-Body Text=<Nextstyle:New\_BG-Body Text><cTypeface:67 Medium Condensed><cSize:11.000000><cAutoPairKern:Optical><cTracking:-5><cLeading:13.000000><pHyphenation:0><cFont:Helvetica Neue LT Std><pDesiredWordSpace:0.950000><pMaxWordSpace:1.000000><pMinWordSpace:0.500000><pDesiredLetterspace:-0.100000><pMinLetterspace:-0.150000><pRuleAboveGapColor:None><pRuleBelowGapColor:None><pDropCapDetail:LeftGlyphEdge><cUnderlineGapColor:None><cStrikeThroughGapColor:None><pShadingColor:Pro Black><pWarichuAlignment:Left><bnColor:None><numFont:\<TextFont\>><rUseOTProGlyph:1><cRubyEdgeSpace:1>>
<DefineParaStyle:NormalParagraphStyle=<Nextstyle:NormalParagraphStyle><cFont:Times><pRuleAboveGapColor:None><pRuleBelowGapColor:None><cUnderlineGapColor:None><cStrikeThroughGapColor:None><pWarichuAlignment:Left><bnColor:None><numFont:\<TextFont\>><rUseOTProGlyph:1><cRubyEdgeSpace:1>>
<DefineParaStyle:New\_SeeOurAd=<BasedOn:NormalParagraphStyle><Nextstyle:New\_SeeOurAd><cTypeface:77 Bold Condensed><cSize:6.500000><cLeading:9.000000><pTabRuler:3\,Right\,.\,0\,\;><cFont:Helvetica Neue LT Std>>' + "\n"
  end

  def company_name(name)
    @styles[:co_name] + name + @line_break
  end
end
