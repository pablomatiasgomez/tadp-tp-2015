require_relative 'conditions.rb'
require_relative 'transforms.rb'

class Origin
  include Conditions
  attr_accessor :target_origin

  def initialize(origin)
    @target_origin=aspects_target(origin)
  end

  def where(*conditions)
    origin_methods(target_origin).select { |origin_method| conditions.all? {|condition| condition.call(target_origin,origin_method)} }
  end

  def transform(origin_methods, &block)
    origin_methods.each do |method|
      optimus_prime = Transformer.new(target_origin.instance_method(method))
      optimus_prime.instance_eval &block
      target_origin.send(:define_method, method, &(optimus_prime.transform_method))
    end
  end

  def aspects_target(origin)
    origin.is_a?(Module) ? origin : origin.singleton_class
  end

  def origin_methods(target_origin)
    (target_origin.instance_methods)+(target_origin.private_instance_methods)
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