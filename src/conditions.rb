class Origin

  def name(regex)
    proc { |_, method| method.match(regex) }
  end

  def is_public
    proc { |origin, method| origin_public_methods(origin).include?(method) }
  end

  def is_private
    proc { |origin, method| origin_private_methods(origin).include?(method)}
  end

  def mandatory #TODO Preguntar porque no me toma en consola si lo meto adentro de has_parameter y si en los tests
    proc { |mode, _| mode == :req }
  end

  def optional
    proc { |mode, _| mode == :opt }
  end

  def has_parameters(count, mode = proc {|p| p})
    condition = mode.is_a?(Regexp) ? proc {|_, p| mode.match(p)} : mode
    proc { |origin, method| origin_method(origin, method).parameters.count(&condition) == count }
  end

  def neg(condition)
    proc { |origin,method| !(condition.call(origin,method)) }
  end

end