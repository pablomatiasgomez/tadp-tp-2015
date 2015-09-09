require_relative 'origin.rb'


class Aspects

  def self.regex_to_origins(regex)
    Object.constants.grep(regex).map {|regex_symbol| Object.const_get(regex_symbol)}
  end

  def self.find_origins(*possible_origins)

    origins = []

    args.map do |possible_origin|
      possible_origin.is_a?(Regexp) ? origins+= regex_to_origins(possible_origin) : origins+= [possible_origin]
    end

    origins.empty? ? (raise 'Error: Empty Origin') : origins.uniq

  end

  def self.on(*possible_origins, &block)
    origin = Origin.new
    origin.origins= find_origins(*possible_origins)

    origin.instance_eval &block
  end

end