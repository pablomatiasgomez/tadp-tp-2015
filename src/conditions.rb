module Conditions

  def name(regex)
    proc { |_, method| method.match(regex) }
  end

  def is_public
    proc { |target_origin, method| target_origin.public_instance_methods.include?(method) }
  end

  def is_private
    proc { |target_origin, method| target_origin.private_instance_methods.include?(method)}
  end

  #Alternativa Aserrin Con Dulce de Leche v2.0
  # ["public","private"].each do
  # |visibility|
  #   define_method("is_#{visibility}") do
  #     proc{ |target_origin,method| target_origin.send("#{visibility}_instance_methods").include? method }
  #   end
  # end

  def is_mode(sym)
    proc { |mode, _| mode == sym }
  end

  def mandatory
    is_mode(:req)
  end

  def optional
    is_mode(:opt)
  end

  def has_parameters(count, mode = proc {|p| p})
    condition = mode.is_a?(Regexp) ? proc {|_, p| mode.match(p)} : mode
    proc { |target_origin, method| target_origin.instance_method(method).parameters.count(&condition) == count }
  end

  def neg(*conditions)
    proc { |target_origin,method| conditions.none? { |condition| condition.call(target_origin,method) } }
  end

end