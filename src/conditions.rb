class Origin

  def name(regex)
    proc { |_, method| method.match(regex) }
  end

  def is_public
    proc { |origin, method| public_origin_method(origin).include?(method) }
  end

  def is_private
    proc { |origin, method| private_origin_method(origin).include?(method)}
  end

  def mandatory #Preguntar porque no me toma en consola si lo meto adentro de has_parameter y si en los tests
    proc { |mode, _| mode == :req }
  end

  def optional
    proc { |mode, _| mode == :opt }
  end

  def has_parameters(count, mode = proc {|p| p})
    if mode.is_a?(Regexp)
      proc { |origin, method| (origin_method(origin, method).parameters.select{ |_, p| p.nil? ? false : p.match(mode) }.length) == count }
    else
      proc { |origin, method| (origin_method(origin, method).parameters.select(&mode).length) == count }
    end
  end

  def neg(condition)
    proc { |origin_method| !(condition.call(origin_method)) }
  end

end