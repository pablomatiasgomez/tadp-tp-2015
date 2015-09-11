require_relative 'conditions.rb'
require_relative 'transforms.rb'

class Origin
  attr_accessor :origins, :methods_to_transform

  def where(*conditions)
    @methods_to_transform= []
    origins.each do |origin|
      @methods_to_transform+= get_origin_methods(origin)
    end

    methods_to_transform.select! do |origin_method|
      conditions.all? do |condition|
        condition.call(origin_method)
      end
    end

    methods_to_transform
  end

  def transform(origin_methods, &block)
    origin_methods.each do |origin, method|
      optimus_prime = Transformer.new(origin_method(origin, method))
      optimus_prime.instance_eval &block
      aspects_target(origin).send(:define_method, method, &(optimus_prime.transform_method))
    end
  end

  def aspects_target(origin)
    origin.is_a?(Module) ? origin : origin.singleton_class
  end

  def get_origin_methods(origin)
    ((aspects_target(origin).instance_methods)+(aspects_target(origin).private_instance_methods)).map { |method| [origin,method ] }
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

end