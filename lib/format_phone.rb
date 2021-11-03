require 'Phony'
require 'Phone'

class FormatPhone
  def initialize(number, country)
    pn_string = number ? number.to_s : ''
    unless pn_string.blank?
      if (
           country == 'United States' || country == 'Canada' ||
             country.to_s.length < 1
         )
        pn_string = pn_string.prepend('+1') if (pn_string.initial != '1')

        if (Phoner::Phone.valid? pn_string)
          pn = Phoner::Phone.parse(pn_string, country_code: '1')
          pn_formatted = pn.format('(%a) %f-%l %x')
          return pn_formatted.strip
        else
          return pn_string
        end
      else
        if Phony.plausible?(pn_string)
          pn = Phony.normalize(pn_string)
          pn_formatted = Phony.format(pn)
          return pn_formatted
        else
          return pn_string
        end
      end
    end
    pn_string
  end
end
