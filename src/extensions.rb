class Object
  def get_origin_methods
    ((aspects_target.instance_methods)+(aspects_target.private_instance_methods)).map { |method| [self,method ] }
  end

  def origin_method(method_sym)
    aspects_target.instance_method(method_sym)
  end

  def aspects_target
    singleton_class
  end
end

class Module
  def aspects_target
    self
  end
end