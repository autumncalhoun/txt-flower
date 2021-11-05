#!/usr/bin/env ruby
require 'tty-prompt'
require 'YAML'
require 'csv'
require_relative './suppliers_generator.rb'
require_relative './alphabetical_index_generator.rb'
require_relative './cross_reference_generator.rb'
require_relative './category_index_generator.rb'

def prompt_start(flower_company)
  prompt = TTY::Prompt.new
  print "Starting tagged text wizard for #{flower_company}..."
  prompt.keypress('Press any key to continue, starts automatically in :countdown ...', timeout: 30)
  system 'clear'
end

def print_csv_requirements(flower_company, template)
  prompt = TTY::Prompt.new
  csv_files = template['csv_files']
  text_files = template['tagged_text_files']

  prompt.say(
    "#{flower_company} requires (#{csv_files.count}) CSV files and generates (#{text_files.count}) tagged text files.\n\n",
  )
  prompt.say('Required CSV files:')
  csv_files.each { |file_name| prompt.say("- #{file_name}.csv", color: :cyan) }
  print "\n"
end

def prompt_csv_dir(flower_company)
  prompt = TTY::Prompt.new
  current_year = Date.today.year
  prompt.ask(
    'Where are the source CSV files?',
    default: "~/src/tagged_text/#{flower_company.downcase}/#{current_year}",
    convert: :filepath,
  )
end

def validate_csvs(location, template)
  valid = []
  csv_files = template['csv_files']
  csv_files.each { |file_name| valid.push(validate_csv("#{location}/#{file_name}.csv", file_name, template)) }
  exit if valid.include?(false)
end

def validate_csv(location, filename, template)
  prompt = TTY::Prompt.new
  template_headers = template['csv_headers'][filename.downcase].map { |header| header[1] }
  headers = CSV.read(location, headers: true).headers
  template_headers.each { |header| raise "Incorrect header: #{header} in #{location}" unless headers.include? header }
rescue => e
  prompt.error("❌ #{e}")
  false
else
  prompt.ok("✅ #{location}")
  true
end

def prompt_text_files(template)
  prompt = TTY::Prompt.new
  choices = template['tagged_text_files']
  prompt.multi_select('Which files do you want to generate?', choices, min: 1)
end

def prompt_output_dir(flower_company)
  prompt = TTY::Prompt.new
  current_year = Date.today.year
  prompt.ask(
    'Where should the tagged text files go?',
    default: "~/src/tagged_text/#{flower_company.downcase}/#{current_year}/test",
    convert: :filepath,
  )
end

def generate(csv_dir, output_dir, text_files)
  prompt = TTY::Prompt.new
  text_files.each do |file|
    # TODO: make this dynamic based on yml entry for generator?

    case file
    when 'AlphabeticalIndexTT'
      Impressions::AlphabeticalIndexGenerator.new(csv: "#{csv_dir}/Company_Category.csv", output_location: output_dir)
        .generate_text
    when 'CategoryIndexTT'
      Impressions::CategoryIndexGenerator.new(csv: "#{csv_dir}/Company_Category.csv", output_location: output_dir)
        .generate_text
    when 'CrossReferenceTT'
      Impressions::CrossReferenceGenerator.new(
        companies_csv: "#{csv_dir}/Companies.csv",
        company_category_csv: "#{csv_dir}/Company_Category.csv",
        output_location: output_dir,
      ).generate_text
    when 'SuppliersTT'
      Impressions::SuppliersGenerator.new(
        companies_csv: "#{csv_dir}/Companies.csv",
        branches_csv: "#{csv_dir}/Branches.csv",
        output_location: output_dir,
      ).generate_text
    end

    prompt.ok("Generated #{file} in #{output_dir}")
  end
end

template = YAML.safe_load(File.open('./lib/impressions/impressions.yml'))
flower_company = 'IMPRESSIONS'

prompt_start(flower_company)
print_csv_requirements(flower_company, template)

csv_dir = prompt_csv_dir(flower_company)
validate_csvs(csv_dir, template)

text_files = prompt_text_files(template)

output_dir = prompt_output_dir(flower_company)

generate(csv_dir, output_dir, text_files)
