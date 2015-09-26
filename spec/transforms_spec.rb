require 'rspec'
require_relative '../src/aspects.rb'
require_relative 'test_classes'


describe 'Origin Transforms' do

  before(:each) do
    $setup.call
  end

  context 'Inject Parameters Transform' do

    let(:mi_class_instance) { MyClass.new }

    let(:transform_methods) { 
      Aspects.on MyClass do
        transform(where has_parameters(1,/p2/)) do
          inject(p2: 'bar')
        end
      end
    }

    it 'should print foo-bar (bar is already injected)' do
      transform_methods
      expect(mi_class_instance.do_something("foo")).to eq("foo-bar")
    end

    it 'should print foo-bar' do
      transform_methods
      expect(mi_class_instance.do_something("foo", "foo")).to eq("foo-bar")
    end

    it 'should print bar:foo' do
      transform_methods
      expect(mi_class_instance.do_another_something("foo", "foo")).to eq("bar:foo")
    end

    it 'should BOOM raising NoParameterException' do
      expect {
        Aspects.on MyClass do
          transform( where has_parameters(1, /p2/)) do
            inject(asdasd: proc { |receptor, mensaje, arg_anterior| "bar(#{mensaje}->#{arg_anterior})" })
          end
        end 
      }.to raise_exception(NoParameterException)
    end

    it 'should print foo-bar and the proc (selector->old_parameter)' do
      Aspects.on MyClass do
        transform( where has_parameters(1, /p2/)) do
          inject(p2: proc { |receptor, mensaje, arg_anterior| "bar(#{mensaje}->#{arg_anterior})" })
        end
      end

      expect(mi_class_instance.do_something("foo", "foo")).to eq("foo-bar(do_something->foo)")
    end

  end

  context 'Redirect Transform' do
    it 'should redirect Hi World to Bye Bye World' do
      Aspects.on A do
        transform( where name(/say_hi/)) do
          redirect_to(B.new)
        end
      end

      expect(A.new.say_hi("World")).to eq("B says: Hi, World")
    end
  end

  context 'Inject Code Transform' do

    let(:sarlompa) {ClassWithAttrX.new}

    it 'should do the before block before the method' do
      Aspects.on ClassWithAttrX do
        transform(where name(/x_plus_y/)) do
          before do |cont, *args|
            @x = 10
            new_args = args.map { |arg| arg*10 }
            cont.call(*new_args)
          end
        end
      end

      expect(sarlompa.x_plus_y(1, 2)).to be(30)
      expect(sarlompa.x).to be(10)
    end

    it 'should do the after block after the method' do
      Aspects.on ClassWithAttrX do
        transform(where name(/set_x_1/)) do
          after do |*args|
            if @x > 100
              2*@x
            else
              @x
            end
          end
        end
      end

      expect(sarlompa.set_x_1(10)).to be(10)
      expect(sarlompa.set_x_1(200)).to be(400)
    end

    it 'should get 133 instead of the result of m3' do
      Aspects.on ClassWithAttrX do
        transform(where name ( /set_x_1/ )) do
          instead_of do | *args|
            @x=123 + args.at(0)
            self.x
          end
        end
      end

      expect(sarlompa.set_x_1(10)).to be(133)
      expect(sarlompa.x).to be(133)
    end

  end

  context 'Combined Transforms' do

    it 'should combine both transforms' do
      Aspects.on B do
        transform(where name(/say_hi/)) do
          inject(p1: "Tarola")
          instead_of do | *args|
            args[0]+="!"
            "Bye Bye, #{args[0]}"
          end
        end
      end

      expect(B.new.say_hi("World")).to eq("Bye Bye, Tarola!")
    end

    it 'should combine both transforms' do
       Aspects.on B do
        transform(where name(/say_hi/)) do
          inject(p1: 'robert!')
          redirect_to(A.new)
        end
      end
      expect(B.new.say_hi('pepe')).to eq('A says: Hi, robert!')
    end

    it 'should do after and before' do
      Aspects.on ClassWithAttrX do
        transform(where name(/x_plus_param/)) do
          before do |cont, *args|
            @x = 0
            cont.call(*args)
          end
          after do |*args|
            @x*2
          end
        end
      end

      expect(ClassWithAttrX.new.x_plus_param(2)).to eq(4)
    end

    it 'should do inject before instead of and after' do
      Aspects.on ClassWithAttrX do
        transform(where name(/x_plus_y/)) do
          instead_of do |*args|
            @x += args[0]
          end
          before do |cont, *args|
            @x = 0
            cont.call(*args)
          end
          after do |*args|
            @x*args[0]
          end
          inject({x: 2})
        end
      end

      expect(ClassWithAttrX.new.x_plus_y(20000)).to eq(4)
    end

    it 'should win the last transform in same precedence' do
      Aspects.on A do
        transform( where name(/say_hi/)) do
          instead_of do |*args|
            'si fuera la ultima apareceria esto pero no'
          end
          redirect_to(B.new)
        end
      end

      expect(A.new.say_hi("World")).to eq("B says: Hi, World")
    end

    it 'should win the last transform in same precedence' do
      a = A.new

      Aspects.on a do
        transform( where name(/say_hi/)) do
          redirect_to(B.new)
          instead_of do |*args|
            'Ahora que es la ultima, cabe'
          end
        end
      end

      expect(A.new.say_hi("World")).to eq('A says: Hi, World')
      expect(a.say_hi("World")).to eq('Ahora que es la ultima, cabe')
    end

    it 'should do two diferents transforms' do
      a = A.new
      b = Object.new
      b.singleton_class.include(AImpostor)

      Aspects.on A, b do
        transform(where name(/say_bye/), is_private) do
          redirect_to(a)
          end
        transform(where name(/say_hi/)) do
          inject(p1: 'Im a')
        end

      end

      expect(a.say_hi).to eq('A says: Hi, Im a')
      expect(b.say_bye).to eq('A says: Goodbye!')
    end

    it 'should redirect before and after with diferentes @x' do
      s1 = ClassWithAttrX.new
      s2 = ClassWithAttrX.new

      Aspects.on s1 do
        transform(where name(/set_x_1/)) do
          after do |*args|
            @x+100
          end
          before do |cont, *args|
            @x = args[0]
            cont.call(*args)
          end
          redirect_to(s2)
        end
      end

      expect(s1.set_x_1(10)).to eq(110)
      expect(s1.x).to eq(10)
      expect(s2.x).to eq(10)
    end

  end

  context 'Methods with blocks Transforms' do

    it 'should redirect not just the arguments but the block' do
       Aspects.on A do
        transform(where name(/do_something/)) do
          redirect_to(B.new)
        end
      end

      expect(A.new.do_something{ |text| text + "!" }).to eq("I'm B!")
    end

    it 'should apply the before and return without calling cont' do
      Aspects.on B do
        transform(where has_parameters(1, /block/)) do
          before do |cont, *args|
            "hello"
          end
        end
      end

      expect(B.new.do_something{ |text| text + "!" }).to eq("hello")
    end

    it 'should apply the before and return without calling cont' do
      Aspects.on B do
        transform(where has_parameters(1, /block/)) do
          after do |*args|
            "bye"
          end
        end
      end

      expect(B.new.do_something{ |text| text + "!" }).to eq("bye")
    end
  end


  context 'Aspects with regexes' do
    it 'should apply the inject and the after for both saludar and despedir' do
      Aspects.on A, /[AB]/ do
        transform(where name(/say_hi/)) do
          inject(p1: "Roberto")
          after do |*args|
            "God says: Hi, " + args[0] + "!"
          end
        end
      end

      expect(A.new.say_hi "Jose").to eq("God says: Hi, Roberto!")
      expect(B.new.say_hi "Jose").to eq("God says: Hi, Roberto!")
    end
  end

  context 'Aspects with objects' do

    let(:a1) {A.new}
    let(:a2) {A.new}

    it 'should apply instead_of transformation correctly on objects' do
      Aspects.on a1,a2 do
        transform(where name(/do_something/)) do
          instead_of do self end
        end
      end

      expect(a1.do_something).to eq(a1)
      expect(a2.do_something).to eq(a2)
      expect(a1.do_something).to_not eq(a2.do_something)
    end


  it 'should transform all methods just in the given object' do

    toad=A.new
    Aspects.on toad do
      transform(where name(/say/)) do
        instead_of do |someone=''| "Thank you #{someone}! But our method is in another object!" end
        end
    end
    expect(toad.say_hi("mario")).to eq("Thank you mario! But our method is in another object!")
    expect(toad.say_bye).to eq("Thank you ! But our method is in another object!")
    expect(A.new.say_hi("mario")).to eq("A says: Hi, mario")
    expect(A.new.say_bye).to eq("A says: Goodbye!")
    end
  end




end