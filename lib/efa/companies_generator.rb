require 'pry'

module EFA
  class CompaniesGenerator
    attr_accessor :csv_location, :output_dir, :template, :tags, :company_rows

    def initialize(csv_location:, output_dir:)
      @csv_location = csv_location
      @output_dir = output_dir
      @template = YAML.safe_load(File.open('./lib/efa/efa.yml'))
      @tags = @template['tagged_text_files'].select! do |file_meta|
        file_meta['tags'] if file_meta['generator'] == 'Companies'
      end
      @company_rows = CSV.read(@csv_location, headers: true)
    end

    def generate_text
      output = File.open(output_dir, 'w')
      # output << template['tagged_text_files']['header']
      # output << company_list
      output.close
    end

    def generate_output
      company_rows.map {|a| a[col_name('name')].slice(0, 5)}.join(', ')
    end

    def col_name(property)
      template['csv_headers']['companies'][property]
    end
  end
end