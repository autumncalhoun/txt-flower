#!/usr/bin/env ruby
require 'tty-prompt'
require 'YAML'
require 'csv'

def prompt_start(flower_company)
  prompt = TTY::Prompt.new
  print "Starting tagged text wizard for #{flower_company}..."
  prompt.keypress("Press any key to continue, starts automatically in :countdown ...", timeout: 30)
  system 'clear'
end

def print_csv_requirements(flower_company, template)
  prompt = TTY::Prompt.new
  csv_files = template['csv_files']
  text_files = template['tagged_text_files']

  prompt.say("#{flower_company} requires (#{csv_files.count}) CSV files and generates (#{text_files.count}) tagged text files.\n\n")
  prompt.say('Required CSV files:')
  csv_files.each { |file_name| prompt.say("- #{file_name}.csv", color: :cyan) }
  print "\n"
end

def prompt_csv_dir
  prompt = TTY::Prompt.new
  current_year = Date.today.year
  prompt.ask('Where are the source CSV files?',
             default: "~/src/tagged_text/impressions/#{current_year}",
             convert: :filepath)
end

def validate_csvs(location, template)
  csv_files = template['csv_files']
  csv_files.each do |file_name|
    validate_csv("#{location}/#{file_name}.csv", file_name, template)
  end
end

def validate_csv(location, filename, template)
  prompt = TTY::Prompt.new
  template_headers = template['csv_headers'][filename.downcase].map{ |header| header[1] }
  headers = CSV.read(location, headers: true).headers
  template_headers.each do |header|
    raise "CSV doesn't have the correct headers - #{header} in #{location}" unless headers.include? header
  end
rescue => e
  prompt.error("*** ERROR ***: #{e}")
else
  prompt.ok("#{location} exists and has the right headers!")
end

def prompt_text_files(template)
  prompt = TTY::Prompt.new
  choices = template['tagged_text_files']
  prompt.multi_select("Which files do you want to generate?", choices)
end

def generate(text_files)
  prompt = TTY::Prompt.new
  prompt.say("Generating...#{text_files.join(', ')}")
end

template = YAML.safe_load(File.open('./lib/impressions/impressions.yml'))
flower_company = 'IMPRESSIONS'

prompt_start(flower_company)
print_csv_requirements(flower_company, template)

csv_dir = prompt_csv_dir
validate_csvs(csv_dir, template)

text_files = prompt_text_files(template)

generate(text_files)
