require_relative 'origin.rb'

class Aspects

  def self.known_modules &filter
    Object.constants.map(&Object.method(:const_get)).grep(Module).select(&filter)
  end

  def self.regex_to_origins regex
    known_modules{|mod|mod.name.match regex}
  end

  def self.interface_to_origins interface
    known_modules{|mod|interface.all?{|method|mod.method_defined? method}}
  end

  def self.to_origins possible_origin
    case possible_origin
      when Regexp
        regex_to_origins possible_origin
      when Array
        interface_to_origins possible_origin
      when Module
        possible_origin
      when Object
        possible_origin.singleton_class
    end
  end

  def self.find_origins *possible_origins
    origins = possible_origins.flat_map &method(:to_origins)

    raise EmptyOriginException.new("Can't call Aspects.on without origins to transform") if origins.empty?
    origins.uniq
  end

  def self.on *possible_origins, &block
    find_origins(*possible_origins).flat_map { |origin| Origin.new(origin).instance_eval &block }
  end

end

class EmptyOriginException < Exception

end