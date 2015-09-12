class Transformer
  attr_accessor :origin, :inject_hash, :before_method, :method, :after_method

  def initialize(origin, method_to_transform)
    @origin = origin
    @original_method = @method = origin.instance_method(method_to_transform)
    @inject_hash = {}
    @before_method = nil
    @after_method = nil
  end

  def transform_method(&transforms)
    instance_eval &transforms

    original_method = @original_method
    method= @method
    inject_hash=@inject_hash
    before_method=@before_method
    after_method=@after_method

    @origin.send(:define_method, original_method.name) do
      |*parameters|
      method= method.is_a?(UnboundMethod) ? method.bind(self) : method
      inject_hash.each do |insert_index, value|
        value.is_a?(Proc) ? insert_value= value.call(self, original_method.name, parameters.at(insert_index))
                          : insert_value= value
        parameters[insert_index] = insert_value
      end

      result = before_method.nil? ? instance_exec(*parameters, &method)
                                  : instance_exec(*parameters, &before_method)

      after_method.nil? ? result
                        : instance_exec(*parameters, &after_method)
    end
  end

  def inject(injected_hash_param)
    injected_hash_param.each do |key, value|
      insert_index = @original_method.parameters.find_index { |_, p| p == key }
      insert_index ? @inject_hash.merge!(insert_index=> value)
                   : (raise NoParameterException.new("Cant inject #{key}, #{@old_parameter} hasnt that parameter"))
    end
  end

  def redirect_to(one_object)
    method_symbol = @original_method.name
    @method = proc{ |*parameters| one_object.send(method_symbol, *parameters) }
  end

  def before(&before_code)
    method = @original_method
    @before_method = proc{ |*parameters|
                      method_proc = proc { |_, _, *new_parameters| method.bind(self).call(*new_parameters)}
                      instance_exec(self, method_proc, *parameters, &before_code) }
  end

  def after(&after_code)
    @after_method = proc { |*parameters| instance_exec(self, *parameters, &after_code)}
  end

  def instead_of(&new_method)
    @method = proc { |*parameters| instance_exec(self, *parameters, &new_method) }
  end

end

class NoParameterException < Exception

end