class UnboundMethod

  def inject(injected_param)
    method = self
    index_to_insert = method.parameters.find_index { |_, p| injected_param.key?(p) }
    insert_value = injected_param.fetch(method.parameters.at(index_to_insert).at(1))

    proc { |*params|
      if insert_value.is_a?(Proc)
        insert_value = insert_value.call(self, method.name, params.at(index_to_insert))
      end
      params.insert(index_to_insert,insert_value).delete_at(index_to_insert+1)
      method.bind(self).call(*params) }
  end

end