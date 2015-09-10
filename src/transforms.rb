class Transformer
  attr_accessor :inject_hash, :before_method, :method, :after_method

  def initialize(method_to_transform)
    @original_method = method_to_transform
    @method =method_to_transform
    @inject_hash = {}
    @before_method = nil
    @after_method = nil
  end

  def transform_method
    original_method = @original_method
    method= @method
    inject_hash=@inject_hash
    before_method=@before_method
    after_method=@after_method

    proc {|*parameters|
      method= method.is_a?(UnboundMethod) ? method.bind(self) : method
      inject_hash.each do |key, value|
        index_to_insert = original_method.parameters.find_index { |_, p| p == key }
        value.is_a?(Proc) ? insert_value= value.call(self, original_method.name, parameters.at(index_to_insert)) : insert_value= value
        parameters.insert(index_to_insert,insert_value).delete_at(index_to_insert+1)
      end
      instance_exec(*parameters, &before_method) unless before_method.nil?
      result = instance_exec(*parameters, &method)
      after_method.nil? ? result : instance_exec(*parameters, &after_method)
    }
  end

  def inject(injected_hash_param)
    @inject_hash.merge!(injected_hash_param)
  end

  def redirect_to(one_object)
    method_symbol = @original_method.name
    @method = proc{ |*parameters| one_object.send(method_symbol, *parameters) }
  end

  def before(&before_code)
    method = @original_method #TODO Revisar deberia trabajar con las transformacions anteriores (procs) o considerar el original
    @before_method = proc{ |*parameters|
                          method_proc = proc { |who, _, *new_parameters| method.bind(self).call(*new_parameters)}
                          instance_exec(self, method_proc, *parameters, &before_code) }
  end

  def after(&after_code)
    @after_method = proc { |*parameters| instance_exec(self, *parameters, &after_code)}
  end

  def instead_of(&new_method)
    @method = proc { |*parameters| instance_exec(self, *parameters, &new_method) }
  end

end