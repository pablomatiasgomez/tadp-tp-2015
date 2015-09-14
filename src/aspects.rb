require_relative 'origin.rb'

class Object
  def instance_exec_b(param_block,*args,&posta_block)
    self.class.send(:define_method,:__juegos_de_azar__,&posta_block)
    self.class.send(:define_method,:__mujerzuelas__,&param_block)
    posta_method=self.method(:__juegos_de_azar__)
    param_method=self.method(:__mujerzuelas__)
    self.class.send(:remove_method,:__juegos_de_azar__)
    self.class.send(:remove_method,:__mujerzuelas__)
    posta_method.call(*args,&param_method)
  end
end


class Aspects

  def self.regex_to_origins(regex)
    Object.constants.grep(regex).map(&Object.method(:const_get)).grep(Module)
  end

  def self.find_origins(*possible_origins)
    origins = possible_origins.flat_map { |possible_origin|
        possible_origin.is_a?(Regexp) ? regex_to_origins(possible_origin) : [possible_origin] }

    origins.empty? ? (raise EmptyOriginException.new("Can't call Aspects.on without origins to transform"))
    : origins.uniq
  end

  def self.on(*possible_origins, &block)
    find_origins(*possible_origins).flat_map { |origin| Origin.new(origin).instance_eval &block }
  end

end

class EmptyOriginException < Exception

end