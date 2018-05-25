# Defines entity specific tagging
class EFA < Flower
  # define your allowed files and create a method for tagging each
  TYPES = %w[companies prod_cat_index prod_cat_list].freeze

  # File specific tagging definitions
  def companies
    text = ''
    @data.each do |row|
      text << row['Company_Name']
      text << @line_break
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
end
