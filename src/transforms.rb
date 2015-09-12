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
      |*args|
      method = method.bind(self) if method.is_a?(UnboundMethod)
      instance_exec(*args,&transformations.reverse.reduce(method) { |method,transformation|instance_exec(method,&transformation) })
      end
  end

  def add_transformation(&transformation)
    @transformations << proc { |next_method| proc{|*args| instance_exec(next_method,*args,&transformation) } }
  end

  def replace_method(&new_method)
    @method = new_method
  end

  def inject(hash)
    method_parameter_names=@original_method.parameters.map { |_,n| n }
    method_name=@original_method.name
    hash.keys.each{|key|
      unless method_parameter_names.include?key
        raise NoParameterException.new("Cant inject #{key}, the method doesn't have that parameter")
      end
      }

    add_transformation{|next_method,*args|
    method_parameter_names.each_with_index { |nombre,index|
      if hash.key?(nombre)
        args[index]=(hash[nombre].is_a?Proc) ? hash[nombre].call(self,method_name,args[index]) : hash[nombre]
      end
    }

    instance_exec(*args,&next_method)
    }
  end

  def before(&logic)
    add_transformation{|next_method,*args|
      cont = proc { |_,_,*new_parameters| instance_exec(*new_parameters,&next_method)}
      instance_exec(self, cont, *args, &logic)
    }
  end


  def after(&logic)
    add_transformation{|next_method,*args|
      instance_exec(*args,&next_method)
      instance_exec(self,*args,&logic)
    }
  end

  def instead_of(&logic)
    replace_method { |*args| instance_exec(self,*args,&logic) }
  end

  def redirect_to(target)
    method_name=@original_method.name
    replace_method { |*args|target.send(method_name,*args) }
  end

end

class NoParameterException < Exception

end