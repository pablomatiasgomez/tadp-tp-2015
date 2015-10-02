module Conditions

  def name(regex)
    proc { |method| method.match regex }
  end

  def visibility(visibility)
    proc { |method| visibility_of(method) == visibility}
  end

  def is_public
    visibility :public
  end

  def is_private
    visibility :private
  end

  def mode(sym)
    proc { |mode, _| mode == sym }
  end

  def mandatory
    mode :req
  end

  def optional
    mode :opt
  end

  def has_parameters(count, mode = proc {|p| p})
    condition = mode.is_a?(Regexp) ? proc {|_, p| mode.match(p)} : mode
    proc { |method| target_origin.instance_method(method).parameters.count(&condition) == count }
  end

  def neg(*conditions)
    proc { |method| conditions.none? { |condition| condition.call method } }
  end

end