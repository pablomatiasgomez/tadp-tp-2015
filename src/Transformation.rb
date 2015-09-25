
class Transformation
  attr_accessor :next_method, :proper_transformation

  def initialize(&transformation_logic)
    @proper_transformation=transformation_logic
  end

  def transform(method_to_transform)
     next_method=method_to_transform
     transformation=self.proper_transformation
     proc { |*args, &arg_block| instance_exec_b(arg_block, next_method, *args, &transformation) }
  end

  def consumible(n)
      counter=0
      regular_transformation=self.proper_transformation
      times=n
      self.proper_transformation=proc do
      |next_method,*args,&arg_block|
        if counter >= times
          return instance_exec_b(arg_block,*args,&next_method)
        else
          counter+=1
          return instance_exec_b(arg_block,next_method,*args,&regular_transformation)
        end
      end
  end

end