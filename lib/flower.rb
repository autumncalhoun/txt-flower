require 'csv'
require 'pp'

# Create tagged text for flowing in InDesign documents
class Flower
  def initialize(debug = false, csv_path = './sample-data/company-sample.csv')
    @debug = debug
    @line_break = "\n"
    get_data(csv_path)
  end

  def tag_text
    text = ''
    @data.each do |row|
      text << row['Company_Name']
      text << @line_break
    end
    @output = text
  end

  def generate_text
    tag_text
    display_for_debug if @debug
    write_text
  end

  private

  def get_data(csv_path)
    @data = CSV.read(csv_path, headers: true) unless csv_path.strip.empty?
  end

  def write_text
    output = File.open('./sample-data/CompaniesTT.txt','w')
    output << @output
    output.close
  end

  def display_for_debug
    pp @output
  end
end
