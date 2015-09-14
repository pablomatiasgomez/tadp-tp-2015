require_relative 'object_extension.rb'

class Transformer
  attr_accessor :origin, :original_method, :method, :transformations

  def initialize(origin, method_to_transform)
    @origin = origin
    @original_method = @method = origin.instance_method(method_to_transform)
    @transformations = []
  end

  def transform_method(&transforms)
    instance_eval &transforms

    transformations=@transformations
    method=@method

    @origin.send(:define_method, @original_method.name) do
      |*args, &arg_block|
      method = method.bind(self) if method.is_a?(UnboundMethod)
      instance_exec_b(arg_block, *args, &transformations.reduce(method) {
                                   |method, transformation, &arg_block|instance_exec_b(arg_block, method, &transformation) })
      end
  end

  def add_transformation(&transformation)
    @transformations << proc { |next_method| proc{|*args, &arg_block| instance_exec_b(arg_block, next_method, *args, &transformation) } }
  end

  def replace_method(&new_method)
    @method = new_method
  end

  def inject(hash)
    method_parameter_names=@original_method.parameters.map { |_, n| n }
    method_name=@original_method.name
    hash.keys.each { |key|
      unless method_parameter_names.include?key
        raise NoParameterException.new("Cant inject #{key}, the method doesn't have that parameter")
      end
      }

    add_transformation { |next_method, *args, &arg_block|
    method_parameter_names.each_with_index { |arg_name, index|
      if hash.key?(arg_name)
        args[index] = (hash[arg_name].is_a?Proc) ? hash[arg_name].call(self, method_name, args[index]) : hash[arg_name]
      end
    }

    instance_exec_b(arg_block, *args, &next_method)
    }
  end

  def before(&logic)
    add_transformation{|next_method, *args, &arg_block|
      cont = proc { |_, _, *new_parameters, &arg_block| instance_exec_b(arg_block, *new_parameters, &next_method)}
      instance_exec_b(arg_block, self, cont, *args, &logic)
    }
  end


  def after(&logic)
    add_transformation{|next_method, *args, &arg_block|
      instance_exec_b(arg_block, *args, &next_method)
      instance_exec_b(arg_block, self, *args, &logic)
    }
  end

  def instead_of(&logic)
    replace_method { |*args, &arg_block| instance_exec_b(arg_block, self, *args, &logic) }
  end

  def redirect_to(target)
    method_name=@original_method.name
    replace_method { |*args, &arg_block|target.send(method_name, *args, &arg_block) }
  end

end

class NoParameterException < Exception

end