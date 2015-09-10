class UnboundMethod

  def inject(injected_param)
    method = self
    index_to_insert = method.parameters.find_index { |_, p| injected_param.key?(p) }
    insert_value = injected_param.fetch(method.parameters.at(index_to_insert).at(1))

    proc { |*parameters|
      if insert_value.is_a?(Proc)
        insert_value = insert_value.call(self, method.name, parameters.at(index_to_insert))
      end
      parameters.insert(index_to_insert,insert_value).delete_at(index_to_insert+1)
      method.bind(self).call(*parameters) }
  end

  def redirect_to(one_object)
    method = self
    proc{ |*parameters| one_object.send(method.name, *parameters) }
  end

  def before(&before_code)
    method = self
    proc{ |*parameters|
          method_proc = proc { |who, _, *new_parameters| method.bind(self).call(*new_parameters)}
          instance_exec(self, method_proc, *parameters, &before_code) }
  end

  def after(&after_code)
    method = self
    proc { |*parameters|
            method.bind(self).call(*parameters)
            instance_exec(self, *parameters, &after_code)}
  end

  def instead_of(&new_method)
    proc { |*parameters| instance_exec(self, *parameters, &new_method) }
  end

end