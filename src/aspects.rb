require_relative 'origin.rb'

class Aspects

  def self.regex_to_origins(regex)
    Object.constants.grep(regex).map(&Object.method(:const_get)).grep(Module)
  end

  def self.find_origins(*possible_origins)
    origins = possible_origins.flat_map { |possible_origin|
                                possible_origin.is_a?(Regexp) ? regex_to_origins(possible_origin) : [possible_origin] }

    origins.empty? ? (raise EmptyOriginException.new("Cant call Aspects.on without oirigins to transform"))
                   : origins.uniq
  end

  def self.on(*possible_origins, &block)
    origins = find_origins(*possible_origins)
    origins.flat_map do |origin|
      Origin.new(origin).instance_eval &block
    end
  end

end


class EmptyOriginException < Exception
end
