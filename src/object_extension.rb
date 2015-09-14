class Object

  def instance_exec_b(param_block, *args, &method_block)
    self.class.send(:define_method, :__juegos_de_azar__, &method_block)
    param_block ? self.class.send(:define_method, :__mujerzuelas__, &param_block)
                : self.class.send(:define_method, :__mujerzuelas__, proc)

    posta_method = self.method(:__juegos_de_azar__)
    param_method=self.method(:__mujerzuelas__)

    self.class.send(:remove_method, :__juegos_de_azar__)
    self.class.send(:remove_method, :__mujerzuelas__)

    posta_method.call(*args, &param_method)
  end

end