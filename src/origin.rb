require_relative 'conditions.rb'
require_relative 'transforms.rb'

class Origin
  attr_accessor :origin

  def initialize(origin)
    @origin=origin
  end

  def where(*conditions)
    origin_methods(origin).select { |origin_method| conditions.all? {|condition| condition.call(origin,origin_method)} }
  end

  def transform(origin_methods, &block)
    origin_methods.each do |method|
      optimus_prime = Transformer.new(origin_method(origin, method))
      optimus_prime.instance_eval &block
      origin_define_method(origin,method,&(optimus_prime.transform_method))
    end
  end

  def aspects_target(origin)
    origin.is_a?(Module) ? origin : origin.singleton_class
  end

  def origin_methods(origin)
    (aspects_target(origin).instance_methods)+(aspects_target(origin).private_instance_methods)
  end

  def origin_method(origin, method_sym)
    aspects_target(origin).instance_method(method_sym)
  end

  def origin_public_methods(origin)
    aspects_target(origin).public_instance_methods
  end

  def origin_private_methods(origin)
    aspects_target(origin).private_instance_methods
  end

  def origin_define_method(origin,method_name,&logic)
    aspects_target(origin).send(:define_method, method_name, &logic)
  end

# Alternativa Aserrin con dulce de leche (Casi Superadora)
# { :origin_method => :instance_method,
#   :origin_public_methods => :public_instance_methods,
#   :origin_private_methods => :private_instance_methods,
#   :origin_define_method => :define_method}.each_pair do |my_method, original_method|
#   define_method(my_method) do |origin,*parameters,&block|
#     aspects_target(origin).send(original_method,*parameters,&block)
#   end
# end

end