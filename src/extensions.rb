module Aspectable
  def get_origin_methods
    ((aspects_target.instance_methods)+(aspects_target.private_instance_methods)).map { |method| [self,method ] }
  end
  def origin_method(method_sym)
    aspects_target.instance_method(method_sym)
  end
end

module ClassAspectable
  include Aspectable
  def aspects_target
    self
  end
end

module InstanceAspectable
  include Aspectable
  def aspects_target
    singleton_class
  end
end

Object.include(InstanceAspectable)
Module.include(ClassAspectable)

# Alternativa superadora
# [Object,Module].each_with_index do
#   |coso,i|
#   coso.include([InstanceAspectable,ClassAspectable].at(i))
# end
# Alternativa cucurucho elemental
# {Object:InstanceAspectable,Module:ClassAspectable}.each_pair do |coso,i|
#   Object.const_get(coso).include(i)
# end