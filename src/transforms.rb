require_relative 'object_extension.rb'
require_relative 'transformation.rb'

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

  known_transformations=[:instead_of,:before,:after,:redirect_to,:inject]

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
      transformed_method = transformations.reduce(base_method){ |method, transformation| transformation.transform(method) }
      instance_exec_b(arg_block, *args, &transformed_method)
    end
  end

  def add_transformation(precedence, &transformation)
    transformation  = Transformation.new &transformation
    @transformations[precedence] << transformation
    transformation
  end

  def inject(hash,precedence=2)
    method_parameter_names = @original_method.parameters.map { |_, n| n }
    method_name = @original_method.name
    hash.keys.each { |key|
      unless method_parameter_names.include?key
        raise NoParameterException.new("Cant inject #{key}, #{method_name} doesn't have that parameter")
      end }

    add_transformation(precedence) { |old_method, *args, &arg_block|
    method_parameter_names.each_with_index { |arg_name, index|
      if hash.key?(arg_name)
        args[index] = (hash[arg_name].is_a?Proc) ? hash[arg_name].call(self, method_name, args[index]) : hash[arg_name]
      end }

    instance_exec_b(arg_block, *args, &old_method) }
  end

  def before(precedence=1,&before_logic)
    add_transformation(precedence) {|old_method, *args, &arg_block|
      instance_exec_b(arg_block, old_method, *args, &before_logic) }
  end


  def after(precedence=1,&after_logic)
    add_transformation(precedence) { |old_method, *args, &arg_block|
      instance_exec_b(arg_block, *args, &old_method)
      instance_exec_b(arg_block, *args, &after_logic) }
  end

  def instead_of(precedence=0,&instead_of_logic)
    add_transformation(precedence) { |_, *args, &arg_block| instance_exec_b(arg_block, *args, &instead_of_logic) }
  end

  def redirect_to(target,precedence=0)
    method_name = @original_method.name
    add_transformation(precedence) { |_, *args, &arg_block|target.send(method_name, *args, &arg_block) }
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