require_relative 'conditions.rb'
require_relative 'transforms.rb'

class Origin
  attr_accessor :origin

  def initialize(origin)
    @origin=origin
  end

  def where(*conditions)
    get_origin_methods(origin).select { |origin_method|
      conditions.all? {|condition| condition.call(origin,origin_method)}
    }
  end

  def transform(origin_methods, &block)
    origin_methods.each do |method|
      optimus_prime = Transformer.new(origin_method(origin, method))
      optimus_prime.instance_eval &block
      define_origin_method(origin,method,&(optimus_prime.transform_method))
    end
  end

  def aspects_target(origin)
    origin.is_a?(Module) ? origin : origin.singleton_class
  end

  def get_origin_methods(origin)
    (aspects_target(origin).instance_methods)+(aspects_target(origin).private_instance_methods)
  end

  def origin_method(origin, method_sym)
    aspects_target(origin).instance_method(method_sym)
  end

  def public_origin_method(origin)
    aspects_target(origin).public_instance_methods
  end

  def private_origin_method(origin)
    aspects_target(origin).private_instance_methods
  end

  def define_origin_method(origin,method_name,&logic)
    aspects_target(origin).send(:define_method, method_name, &logic)
  end

end