require 'rspec'
require_relative '../src/aspects.rb'
require_relative 'test_classes'


describe 'Origin Transforms' do

  context 'Inject Parameters Transform' do

    let(:mi_class_instance) { MyClass.new }

    let(:transform_methods) { Aspects.on mi_class_instance do
                                transform(where has_parameters(1,/p2/)) do
                                  inject(p2: 'bar')
                                end
                              end }

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

    expect(A.new.say_hi("World")).to eq("Bye Bye, World")
    end

  end

  context 'Inject Code Transform' do

    let(:sarlompa) {SarlompaClass.new}

    it 'should do the before block before the method' do
      Aspects.on SarlompaClass do
        transform(where name(/m1/)) do
          before do |instance, cont, *args|
            @x = 10
            new_args = args.map { |arg| arg*10 }
            cont.call(self ,nil , *new_args)
          end
        end
      end

      expect(sarlompa.m1(1, 2)).to be(30)
      expect(sarlompa.x).to be(10)
    end

    it 'should do the after block after the method' do
      Aspects.on SarlompaClass do
        transform(where name(/m2/)) do
          after do |instance, *args|
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

    it 'should get 123 instead of the result of m3' do
      Aspects.on SarlompaClass do
        transform(where name ( /m3/ )) do
          instead_of do |instance , *args|
            @x=123
            instance.x
          end
        end
      end

      expect(sarlompa.m3(10)).to be(123)
      expect(sarlompa.x).to be(123)
    end

  end

end