require 'Phony'
require 'Phone'

class String
  def initial
    self[0, 1]
  end
  def initial2
    self[0, 2]
  end
end

class PhoneNumber
  attr_accessor :country
  def initialize(number:, country:)
    @number = number.to_s || ''
    @country = country.to_s
  end

  def format()
    return @number unless formattable?

    if (domestic?)
      return parse_with_phoner
    else
      return parse_with_phony
    end
  end

  private

  def parse_with_phony
    return @number unless Phony.plausible?(@number)
    pn = Phony.normalize(@number)
    return Phony.format(pn)
  end

  def parse_with_phoner
    @number = @number.prepend('+1') unless prefixed?
    return @number unless Phoner::Phone.valid? @number
    Phoner::Phone.parse(@number, country_code: '1').format('(%a) %f-%l %x').strip
  end

  def prefixed?
    @number.initial == '1' || @number.initial2 == '+1'
  end

  def domestic?
    country == 'United States' || country == 'Canada' || country.blank?
  end

  def formattable?
    !@number.blank? && !vanity_number?
  end

  def vanity_number?
    @number.count('a-zA-Z') > 0
  end
end
