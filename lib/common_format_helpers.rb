require 'Phony'
require 'Phone'

# Common methods for formatting
module CommonFormatHelpers
  def line_break
    "\n"
  end

  def format_phone(number, country)
    pn_string = number.to_s
    return pn_string if pn_string.blank?
    return pn_string if vanity_number(pn_string)

    domestic_countries = ['United States', 'Canada']
    if domestic_countries.include?(country)
      pn_string = pn_string.prepend('+1') if pn_string.initial != '1'

      return pn_string unless Phoner::Phone.valid? pn_string

      pn = Phoner::Phone.parse(pn_string, country_code: '1')
      pn_formatted = pn.format('(%a) %f-%l %x')
      return pn_formatted.strip
    else
      return pn_string unless Phony.plausible?(pn_string)
      pn = Phony.normalize(pn_string)
      pn_formatted = Phony.format(pn)
      return pn_formatted
    end
  end

  def vanity_number(number)
    number.count('a-zA-Z') > 0
  end
end
