require_relative 'extensions.rb'
require_relative 'conditions.rb'
require_relative 'transforms.rb'

class Origin
  attr_accessor :origins, :methods_to_transform

  def where(*conditions)
    @methods_to_transform= []
    origins.each do |origin|
      @methods_to_transform+= origin.get_origin_methods
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
      new_method = origin.origin_method(method).instance_eval(&block)
      origin.aspects_target.send(:define_method, method, new_method )
    end

  end

end