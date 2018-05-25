class FormatAddress
  def initialize(row, row_style)
    line_break = "/n"
    city = row['City']

    @text = row_style + city + line_break
  end

  def return_string
    @text
  end
end
