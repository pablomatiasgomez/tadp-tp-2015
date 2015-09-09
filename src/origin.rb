require_relative 'extensions.rb'

class Origin
  attr_accessor :origins

  def name(regex)
    proc { |_, method| method.match(regex) }
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