require 'csv'
require 'pp'
require 'fileutils'

# Create tagged text for flowing in InDesign documents
class Flower
  attr_accessor :file_name
  attr_accessor :type

  def initialize(file_name = '', debug = false, csv_path = './sample_data/company-sample.csv')
    @debug = debug
    @line_break = "\n"
    tagged_text_type(file_name)
    get_data(csv_path)
  end

  def generate_text
    if @type.strip.empty?
      self.class::TYPES.each do |type|
        tagged_text_type(type)
        tag_and_write
      end
    else
      tag_and_write
    end
  end

  private

  def tagged_text_type(file_name)
    @file_name = file_name + '_TT.txt'
    @type = file_name
  end

  def tag_text
    send(@type)
  end

  def tag_and_write
    tag_text
    display_for_debug if @debug
    write_text
  end

  def create_dir
    year = Time.now.year
    directory_name = "tagged_text/#{self.class.name}/#{year}"
    FileUtils::mkdir_p directory_name unless Dir.exist?(directory_name)
    directory_name
  end

  def get_data(csv_path)
    @data = CSV.read(csv_path, headers: true) unless csv_path.strip.empty?
  end

  def write_text
    directory_name = create_dir
    output = File.open("#{directory_name}/#{file_name}",'w')
    output << @output
    output.close
  end

  def display_for_debug
    puts '🌻'
    pp @output
    puts '🌻'
  end
end
