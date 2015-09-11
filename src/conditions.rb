module WithCondition

  def name(regex)
    proc { |_, method| method.match(regex) }
  end

  def is_public
    proc { |target_origin, method| target_origin.public_instance_methods.include?(method) }
  end

  def is_private
    proc { |target_origin, method| target_origin.private_instance_methods.include?(method)}
  end

  def mandatory #TODO Preguntar porque no me toma en consola si lo meto adentro de has_parameter y si en los tests
    proc { |mode, _| mode == :req }
  end

  def optional
    proc { |mode, _| mode == :opt }
  end

  def has_parameters(count, mode = proc {|p| p})
    condition = mode.is_a?(Regexp) ? proc {|_, p| mode.match(p)} : mode
    proc { |target_origin, method| target_origin.instance_method(method).parameters.count(&condition) == count }
  end

  def neg(condition)
    proc { |target_origin,method| !(condition.call(target_origin,method)) }
  end

end