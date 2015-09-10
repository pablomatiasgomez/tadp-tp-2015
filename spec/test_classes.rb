class Sarasa
  def foo ( p1 , p2 , p3 , p4 = 'a' , p5 = 'b' , p6 = 'c' )
  end
  def bar ( p1 , p2 = 'a' , p3 = 'b' , p4 = 'c' )
  end
end

class TestClass
  def foo
  end
  private
  def bar
  end
end

module Marasa
  def foo ( param1 , param2 )
  end
  def bar ( param1 )
  end
end

module TestModule
  def foo1(p1)
  end
  def foo2(p1, p2)
  end
  def foo3(p1, p2, p3)
  end
end

class MyClass
  def do_something(p1, p2)
    p1 + '-' + p2
  end
  def do_another_something(p2, ppp)
    p2 + ':' + ppp
  end
end

class A
  def say_hi(x)
    "Hi, "+x
  end
end

class B
  def say_hi(x)
    "Bye Bye, "+x
  end
end

class SarlompaClass
  attr_accessor :x
  def m1(x, y)
    @x+y
  end
  def m2(x)
    @x = x
  end
  def m3(x)
    @x = x
  end
end