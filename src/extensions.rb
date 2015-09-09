class Object
  def get_origin_methods
    aspects_target.instance_methods.map { |method| [self,method ] }
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

class Class
  def aspects_target
    self
  end
end