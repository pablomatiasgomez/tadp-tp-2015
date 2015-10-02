require_relative 'object_extension.rb'

class MultiLevelQueue < Array

  def [](n)
    super(n) || self[n] = []
  end

  def to_list
    compact.flatten
  end

end

class Transformation

  def initialize &transformation
    @transformation = transformation
  end

  def transform method,target
    transformation=@transformation
    proc  { |*args, &arg_block| target.instance_exec_b(arg_block, method, *args, &transformation) }
  end

  def consumible n
    counter=0
    regular_transformation=@transformation
    times=n
    @transformation=proc do
      |next_method,*args,&arg_block|
      if counter >= times
        return instance_exec_b(arg_block,*args,&next_method)
      else
        counter+=1
        return instance_exec_b(arg_block,next_method,*args,&regular_transformation)
      end
    end
  end

end


class Transformer
  attr_accessor :origin, :original_method, :transformations

  known_transformations=[:instead_of,:before,:after,:redirect_to,:inject]

  def initialize origin, original_method, visibility
    @origin = origin
    @original_method = origin.instance_method original_method
    @transformations = MultiLevelQueue.new
    @visibility = visibility
  end

  def transform_method &transforms
    instance_eval &transforms

    transformations = self.transformations.to_list
    original_method = @original_method

    @origin.send(:define_method, original_method.name) do  |*args, &arg_block|
      transformed_method = transformations.reduce(original_method.bind(self)){ |method, transformation| transformation.transform(method,self) }
      instance_exec_b(arg_block, *args, &transformed_method)
    end

    @origin.send(@visibility, original_method.name)

  end

  def add_transformation precedence, &transformation_block
    transformation = Transformation.new(&transformation_block)
    @transformations[precedence] << transformation
    transformation
  end

  def inject precedence = 2, hash
    method_parameter_names = @original_method.parameters.map { |_, n| n }
    method_name = @original_method.name

    hash.keys.each { |key|
      raise NoParameterException.new("Cant inject #{key}, #{method_name} doesn't have that parameter") unless method_parameter_names.include?key
    }

    before(precedence) do |original_method, *args, &arg_block|
      method_parameter_names.each_with_index do |arg_name, index|
        if hash.key?(arg_name)
          args[index] = (hash[arg_name].is_a?Proc) ? hash[arg_name].call(self, method_name, args[index]) : hash[arg_name]
        end
      end

      original_method.call(*args,&arg_block)
    end
  end

  def before precedence = 1, &before_logic
    add_transformation(precedence) {|original_method, *args, &arg_block|
      instance_exec_b(arg_block, original_method, *args, &before_logic) }
  end


  def after precedence = 1, &after_logic
    before(precedence) do |original_method, *args, &arg_block|
      original_method.call(*args,&arg_block)
      instance_exec_b(arg_block, *args,&after_logic)
    end
  end

  def instead_of precedence = 0, &instead_of_logic
    before(precedence) do |_, *args, &arg_block| instance_exec_b(arg_block, *args, &instead_of_logic) end
  end

  def redirect_to precedence = 0, target
    method_name = @original_method.name
    before(precedence) do |_,*args,&arg_block| target.send(method_name,*args,&arg_block) end
  end

  def consumible times_used,*transformations
    transformations.each {|transformation| transformation.consumible(times_used)}
  end

  known_transformations.each do |transformation_symbol|
        define_method("consumible_#{transformation_symbol}") do |n,*args,&logic|
        transformation = self.send(transformation_symbol,*args,&logic)
        transformation.consumible(n)
        end
    end
end

class NoParameterException < Exception

end