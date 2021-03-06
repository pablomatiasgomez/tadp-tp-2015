require_relative 'origin.rb'

class Aspects

  def self.regex_to_origins(regex)
    Object.constants.grep(regex).map(&Object.method(:const_get)).grep(Module)
  end

  def self.find_origins(*possible_origins)
    origins = possible_origins.flat_map { |possible_origin|
      possible_origin.is_a?(Regexp) ? regex_to_origins(possible_origin) : [possible_origin]
    }

    raise EmptyOriginException.new("Can't call Aspects.on without origins to transform") if origins.empty?
    origins.uniq
  end

  def self.on(*possible_origins, &block)
    find_origins(*possible_origins).flat_map { |origin| Origin.new(origin).instance_eval &block }
  end

end

class EmptyOriginException < Exception

end