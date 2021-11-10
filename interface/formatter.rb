
require_relative './format1'
require_relative './format2'
require_relative './format3'

class Formatter

  def self.for(type)
    case type
    when 'format1'
      Format1.new
    when 'format2'
      Format2.new
    when 'format3'
      Format3.new
    else
      raise 'Unsupported type of format'
    end
  end
end

class FormatGenerator
  def self.generate(type)
    Formatter.for(type).test
  end
end

puts FormatGenerator.generate('format1')
puts FormatGenerator.generate('format2')
puts FormatGenerator.generate('format3')
