module Conditions

  def name(regex)
    proc { |method| method.match(regex) }
  end

  def is_visibility(visibility)
    proc { |method| visibility_of(method)==visibility}
  end

  def is_public
    is_visibility :public
  end

  def is_private
    is_visibility :private
  end

  def is_mode(sym)
    proc { |mode, _| mode == sym }
  end

  def mandatory
    is_mode :req
  end

  def optional
    is_mode :opt
  end

  def has_parameters(count, mode = proc {|p| p})
    condition = mode.is_a?(Regexp) ? proc {|_, p| mode.match(p)} : mode
    proc { |method| target_origin.instance_method(method).parameters.count(&condition) == count }
  end

  def neg(*conditions)
    proc { |method| conditions.none? { |condition| condition.call(origin, method) } }
  end

end