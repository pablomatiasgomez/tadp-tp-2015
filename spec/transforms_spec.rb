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

    let(:sarlompa) {SarlompaClass.new}

    it 'should do the before block before the method' do
      Aspects.on SarlompaClass do
        transform(where name(/m1/)) do
          before do |cont, *args|
            @x = 10
            new_args = args.map { |arg| arg*10 }
            cont.call(*new_args)
          end
        end
      end

      expect(sarlompa.m1(1, 2)).to be(30)
      expect(sarlompa.x).to be(10)
    end

    it 'should do the after block after the method' do
      Aspects.on SarlompaClass do
        transform(where name(/m2/)) do
          after do |*args|
            if @x > 100
              2*@x
            else
              @x
            end
          end
        end
      end

      expect(sarlompa.m2(10)).to be(10)
      expect(sarlompa.m2(200)).to be(400)
    end

    it 'should get 133 instead of the result of m3' do
      Aspects.on SarlompaClass do
        transform(where name ( /m3/ )) do
          instead_of do | *args|
            @x=123 + args.at(0)
            self.x
          end
        end
      end

      expect(sarlompa.m3(10)).to be(133)
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
      Aspects.on SarlompaClass do
        transform(where name(/m4/)) do
          before do |cont, *args|
            @x = 0
            cont.call(*args)
          end
          after do |*args|
            @x*2
          end
        end
      end

      expect(SarlompaClass.new.m4(2)).to eq(4)
    end

    it 'should do inject before instead of and after' do
      Aspects.on SarlompaClass do
        transform(where name(/m1/)) do
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

      expect(SarlompaClass.new.m1(20000)).to eq(4)
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

    it 'should apply transformation correctly on objects' do
      Aspects.on a1,a2 do
        transform(where name(/do_something/)) do
          instead_of do self end
        end
      end

      expect(a1.do_something).to eq(a1)
      expect(a2.do_something).to eq(a2)
      expect(a1.do_something).to_not eq(a2.do_something)
    end
  end

end