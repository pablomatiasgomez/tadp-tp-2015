require_relative 'object_extension.rb'

class MultiLevelQueue < Array
  def [](n)
    super(n) || self[n]=[]
  end
  def to_list
    compact.flatten
  end
end


class Transformer
  attr_accessor :origin, :original_method, :transformations

  def initialize(origin, method_to_transform)
    @origin = origin
    @original_method = origin.instance_method(method_to_transform)
    @transformations = MultiLevelQueue.new
  end

  def transform_method(&transforms)
    instance_eval &transforms

    transformations = self.transformations.to_list
    original_method = self.original_method

    @origin.send(:define_method, @original_method.name) do  |*args, &arg_block|
      base_method = original_method.clone.bind(self)
      transformed_method = transformations.reduce(base_method){ |method, transformation| transformation.call(method) }
      instance_exec_b(arg_block, *args, &transformed_method)
    end
  end

  def add_transformation(precedence, &transformation)
    @transformations[precedence] << proc { |next_method|
              proc{ |*args, &arg_block| instance_exec_b(arg_block, next_method, *args, &transformation) } }
  end

  def inject(hash,precedence=2)
    method_parameter_names = @original_method.parameters.map { |_, n| n }
    method_name = @original_method.name
    hash.keys.each { |key|
      unless method_parameter_names.include?key
        raise NoParameterException.new("Cant inject #{key}, the method doesn't have that parameter")
      end }

    add_transformation(precedence) { |next_method, *args, &arg_block|
    method_parameter_names.each_with_index { |arg_name, index|
      if hash.key?(arg_name)
        args[index] = (hash[arg_name].is_a?Proc) ? hash[arg_name].call(self, method_name, args[index]) : hash[arg_name]
      end }

    instance_exec_b(arg_block, *args, &next_method) }
  end

  def before(precedence=1,&logic)
    add_transformation(precedence) {|next_method, *args, &arg_block|
      instance_exec_b(arg_block, next_method, *args, &logic) }
  end


  def after(precedence=1,&logic)
    add_transformation(precedence) { |next_method, *args, &arg_block|
      instance_exec_b(arg_block, *args, &next_method)
      instance_exec_b(arg_block, *args, &logic) }
  end

  def instead_of(precedence=0,&logic)
    add_transformation(precedence) { |_, *args, &arg_block| instance_exec_b(arg_block, *args, &logic) }
  end

  def redirect_to(target,precedence=0)
    method_name = @original_method.name
    add_transformation(precedence) { |_, *args, &arg_block|target.send(method_name, *args, &arg_block) }
  end

end

class NoParameterException < Exception

end