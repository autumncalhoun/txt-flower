require 'pry'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'Phony'
require 'Phone'
require 'YAML'
require 'fileutils'

module Impressions
  class AlphabeticalIndexGenerator
    attr_accessor :output_location
    def initialize(csv:, output_location:)
      @output_location = output_location
      @data = CSV.read(csv, headers: true)
      @styles = { prod: '<ParaStyle:Product alpha>', abc: '<ParaStyle:ABCs>' }
      @output = ''
      @line_break = "\n"
      @header =
        "<ASCII-MAC>
<Version:11.4><FeatureSet:InDesign-Roman><ColorTable:=<Black:COLOR:CMYK:Process:0,0,0,1><Paper:COLOR:CMYK:Process:0,0,0,0><C\=0 M\=48 Y\=70 K\=0:COLOR:CMYK:Process:0,0.48,0.7,0>>
<DefineParaStyle:Product alpha=<Nextstyle:Product alpha><cSize:7.500000><pHyphenationLadderLimit:0><pLeftIndent:9.000000><pFirstLineIndent:-9.000000><cLeading:8.500000><pHyphenation:0><pHyphenateCapitals:0><pHyphenationZone:0.000000><pSpaceBefore:3.024000><pTabRuler:160\,Right\,.\,0\,.\;><cFont:Adobe Caslon Pro>>
<DefineParaStyle:ABCs=<Nextstyle:ABCs><cColor:Paper><cTypeface:Black><cHorizontalScale:0.930000><cLigatures:0><cCase:All Caps><pHyphenationLadderLimit:0><pLeftIndent:5.399999><cLeading:20.000000><pHyphenation:0><pHyphenateCapitals:0><pHyphenationZone:0.000000><pSpaceAfter:2.880000><pTabRuler:72\,Left\,.\,0\,\;><cFont:Circular Std><pRuleAboveColor:C\=0 M\=48 Y\=70 K\=0><pRuleAboveStroke:15.000000><pRuleAboveTint:100.000000><pRuleAboveOffset:-3.060000><pRuleAboveOn:1><pRuleAboveStrokeType:ThickThick><pRuleAboveGapColor:C\=0 M\=48 Y\=70 K\=0><pRuleAboveGapTint:100.000000><pTextAlignment:Center>>\n"
    end

    def generate_text
      abc_loop
      write_output_to_file
    end

    private

    def write_output_to_file
      FileUtils.mkdir_p output_location unless Dir.exist? output_location
      file = File.open(File.join(output_location, 'ProdAlphaIndexTT.txt'), 'w')
      file << @header
      file << @output
      file.close
    end

    def abc_loop
      # sort by prod, then subproduct
      prod_index = @data.sort_by { |d| [d['Product'].downcase] }
      letters = 0.upto(9).to_a + ('A'..'Z').to_a

      letters.each do |letter|
        filtered_prod = prod_index.select { |item| item['Product'].start_with?(letter.to_s) }
        filtered_subprod =
          prod_index.select { |item| item['Subproduct'] && item['Subproduct'].start_with?(letter.to_s) }
        filtered_subprod = filtered_subprod.sort_by { |d| [d['Subproduct'].downcase] }

        prod_list = ''
        subprod_list = ''
        current_subprod = ''
        current_prod = ''

        filtered_prod.each do |pi|
          prod = pi['Product'] || ''
          if current_prod != prod
            prod_list << @styles[:prod] + prod.upcase + @line_break
            current_prod = prod
          end
        end

        filtered_subprod.each do |pi|
          subprod = pi['Subproduct'] || ''
          if !subprod.blank? && current_subprod != subprod
            subprod_list << @styles[:prod] + subprod + @line_break
            current_subprod = subprod
          end
        end

        if !prod_list.blank? || !subprod_list.blank?
          @output << @styles[:abc] + letter.to_s + @line_break if !letter.is_a? Numeric
          @output << prod_list + subprod_list
        end
      end

      return @output
    end
  end
end
