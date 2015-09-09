require_relative 'extensions.rb'

class Origin
  attr_accessor :origins

  def name(regex)
    proc { |_, method| method.match(regex) }
  end

  def is_public
    proc { |origin, method| origin.aspects_target.public_instance_methods.include?(method)}
  end

  def is_private
    proc { |origin, method| origin.aspects_target.private_instance_methods.include?(method)}
  end

  def mandatory
    proc { |mode, _| mode == :req }
  end

  def optional
    proc { |mode, _| mode == :opt }
  end

  def has_parameters(count, mode = proc {|p| p})
    if mode.is_a?(Regexp)
      proc { |origin, method| (origin.origin_method(method).parameters.select{ |_, p| p.match(mode) }.length) == count}
    else
      proc { |origin, method| (origin.origin_method(method).parameters.select(&mode).length) == count}
    end
  end

  def where(*conditions)
    methods_to_transform = []
    origins.each do |origin|
      methods_to_transform+= origin.get_origin_methods
    end

    methods_to_transform.select! do |method|
      conditions.all? do |condition|
        condition.call(method)
      end
    end

    methods_to_transform
  end

end