class Object

  def instance_exec_b param_block, *args, &method_block
    self.singleton_class.send :define_method, :__juegos_de_azar_y_mujerzuelas__, &method_block

    method = self.method :__juegos_de_azar_y_mujerzuelas__

    self.singleton_class.send :remove_method, :__juegos_de_azar_y_mujerzuelas__

    method.call *args, &param_block
  end

end