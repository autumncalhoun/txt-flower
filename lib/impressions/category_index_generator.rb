module Impressions
  class CategoryIndexGenerator
    attr_accessor :output_location
    def initialize(csv:, output_location:)
      @output_location = output_location
      @data = CSV.read(csv, headers: true)
      @styles = { cat: '<ParaStyle:Category>', subcat: '<ParaStyle:Product>', subsubcat: '<ParaStyle:SubProduct>' }
      @output = ''
      @line_break = "\n"
      @header =
        "<ASCII-MAC>
<Version:11.4><FeatureSet:InDesign-Roman><ColorTable:=<Apparel Blanks:COLOR:CMYK:Process:0.34,0,0.93,0><Black:COLOR:CMYK:Process:0,0,0,1><Blank Nonwear:COLOR:CMYK:Process:0.82,0.38,0,0><Computer Equip:COLOR:CMYK:Process:0.25,1,0.45,0.07><Cutting Equip:COLOR:CMYK:Process:0.91,1,0.18,0.15><Digital:COLOR:CMYK:Process:0.53,0,0.32,0><Embroidery Equip:COLOR:CMYK:Process:0,1,1,0><Heat-App Graphics:COLOR:CMYK:Process:0.68,0,0.04,0><Miscellaneous:COLOR:CMYK:Process:0.8,0,1,0><Screen Printing:COLOR:CMYK:Process:0,0,0,0.75>>
<DefineParaStyle:Category=<Nextstyle:Category><cTypeface:Bold><cSize:9.000000><cHorizontalScale:0.950000><cCase:All Caps><pHyphenationLadderLimit:0><cLeading:11.000000><pHyphenation:0><pHyphenateCapitals:0><pHyphenationZone:0.000000><pSpaceBefore:9.000000><cFont:Circular Std><pKeepWithNext:1>>
<DefineParaStyle:Product=<Nextstyle:Product><cSize:7.000000><cCase:All Caps><pHyphenationLadderLimit:0><pLeftIndent:9.000000><pFirstLineIndent:-9.000000><cLeading:11.000000><pHyphenation:0><pHyphenateCapitals:0><pHyphenationZone:0.000000><pSpaceBefore:3.600000><pTabRuler:160\,Right\,.\,0\,.\;><cFont:Adobe Caslon Pro>>
<DefineParaStyle:SubProduct=<cSize:7.000000><pHyphenationLadderLimit:0><pLeftIndent:18.000000><pFirstLineIndent:-9.000000><cLeading:10.000000><pHyphenation:0><pHyphenateCapitals:0><pHyphenationZone:0.000000><pSpaceBefore:1.500000><pTabRuler:160\,Right\,.\,0\,.\;><cFont:Adobe Caslon Pro>>\n"
    end

    def generate_text
      cat_loop
      write_output_to_file
    end

    private

    def write_output_to_file
      FileUtils.mkdir_p output_location unless Dir.exist? output_location
      file = File.open(File.join(output_location, 'ProdCatIndexTT.txt'), 'w')
      file << @header
      file << @output
      file.close
    end

    def cat_loop
      # sort by cat, then subcat, then sub subcat

      cat_index = @data.sort_by { |d| [d['CategoryName'], d['Product'], d['Subproduct'].to_s] }

      current_cat = ''
      current_subcat = ''
      current_subsubcat = ''

      cat_index.each do |c|
        # Loop through and write the cat, subcat or subsubcat if it has not already been written (so it is unique)
        cat = c['CategoryName']
        subcat = c['Product'] || ''
        subsubcat = c['Subproduct'] || ''

        if current_cat != cat
          @output << @styles[:cat] + cat + @line_break
          current_cat = cat
        end

        if current_subcat != subcat
          @output << @styles[:subcat] + subcat + @line_break
          current_subcat = subcat
        end

        if !subsubcat.blank? && current_subsubcat != subsubcat
          @output << @styles[:subsubcat] + subsubcat + @line_break
          current_subsubcat = subsubcat
        end
      end

      return @output
    end

    def display
      self.cat_loop
      @output
    end

    def write_file
      output = File.open('2020/ProdCatIndexTT.txt', 'w')
      output << @header
      output << @output
      output.close
    end
  end
end
