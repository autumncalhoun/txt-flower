#!/usr/bin/env ruby
require 'tty-prompt'
require 'YAML'
require 'csv'
require_relative './impressions/cli'
require_relative './efa/cli'
require_relative './hcd/cli'
require_relative './hd/cli'

MODULE_CHOICES = %w[EFA Impressions HCD HD]

def prompt_start
  prompt = TTY::Prompt.new
  print 'Starting tagged text wizard...'
  prompt.keypress('Press any key to continue, starts automatically in :countdown ...', timeout: 30)
  system 'clear'
end

def set_module
  prompt = TTY::Prompt.new
  prompt.select('Which module are you tagging?', MODULE_CHOICES)
end

def print_csv_requirements(flower_module, csv_files, text_files)
  prompt = TTY::Prompt.new

  prompt.say(
    "#{flower_module} requires (#{csv_files.count}) CSV files and generates (#{text_files.count}) tagged text files.\n\n",
  )
  prompt.say('Required CSV files:')
  csv_files.each { |file_name| prompt.say("- #{file_name}.csv", color: :cyan) }
  print "\n"
end

def prompt_csv_dir(flower_module)
  prompt = TTY::Prompt.new
  current_year = Date.today.year
  prompt.ask(
    'Where are the source CSV files?',
    default: "~/src/tagged_text/#{flower_module.downcase}/#{current_year}",
    convert: :filepath,
  )
end

def validate_csvs(location, csv_files, klass)
  valid = []
  csv_files.each { |file_name| valid.push(validate_csv("#{location}/#{file_name}.csv", file_name, klass)) }
  exit if valid.include?(false)
end

def validate_csv(location, filename, klass)
  prompt = TTY::Prompt.new
  headers = CSV.read(location, headers: true).headers
  klass
    .csv_headers(filename)
    .each { |header| raise "Incorrect header: #{header} in #{location}" unless headers.include? header }
rescue => e
  prompt.error("❌ #{e}")
  false
else
  prompt.ok("✅ #{location}")
  true
end

def prompt_text_files(text_files)
  prompt = TTY::Prompt.new
  choices = text_files
  prompt.multi_select('Which files do you want to generate?', choices, min: 1)
end

def prompt_output_dir(flower_module)
  prompt = TTY::Prompt.new
  current_year = Date.today.year
  prompt.ask(
    'Where should the tagged text files go?',
    default: "~/src/tagged_text/#{flower_module.downcase}/#{current_year}/test",
    convert: :filepath,
  )
end

def generate(klass, csv_dir, output_dir, text_files)
  prompt = TTY::Prompt.new
  text_files.each do |file|
    klass.use_generator(file: file, csv_dir: csv_dir, output_dir: output_dir)
    prompt.ok("Generated #{file} in #{output_dir}")
  end
end

prompt_start
flower_module = set_module
klass = Module.const_get(flower_module)::CLI.new
csv_files = klass.csv_files
template_text_files = klass.text_files

print_csv_requirements(flower_module, csv_files, template_text_files)

csv_dir = prompt_csv_dir(flower_module)
validate_csvs(csv_dir, csv_files, klass)

text_files = prompt_text_files(template_text_files)

output_dir = prompt_output_dir(flower_module)

generate(klass, csv_dir, output_dir, text_files)
