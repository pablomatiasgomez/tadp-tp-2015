require_relative 'conditions.rb'
require_relative 'transforms.rb'

class Origin
  include Conditions
  attr_accessor :target_origin

  def initialize(origin)
    @target_origin = origin
  end

  def where(*conditions)
    origin_methods(target_origin).select { |origin_method| conditions.all? { |condition| condition.call(origin_method)} }
  end

  def transform(origin_methods, &transforms)
    origin_methods.each { |method| Transformer.new(@target_origin, method, visibility_of(method)).transform_method &transforms }
  end

  def visibility_of(method)
    [:public, :private, :protected].detect do |visibility|
      target_origin.send("#{visibility.to_s}_instance_methods").include? method
    end || (raise NoMethodError)
  end

  def aspects_target(origin)
    origin.is_a?(Module) ? origin : origin.singleton_class
  end

  def origin_methods(target_origin)
    (target_origin.instance_methods)+(target_origin.private_instance_methods)
  end

end