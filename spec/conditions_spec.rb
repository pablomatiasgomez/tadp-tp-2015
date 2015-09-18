require 'rspec'
require_relative '../src/aspects.rb'
require_relative 'test_classes.rb'

describe 'Origins Conditions' do

  let(:object_instance_methods) {Object.instance_methods+Object.private_instance_methods}

  it 'should get the instance methods of Object' do
    no_condition = (Aspects.on Object do
                      where
                    end)

    expect(no_condition).to eq(object_instance_methods)
  end

  context 'Selector Condition' do

    it 'should get foo method (match with regexp /foo{2}/)' do
      name_condition = (Aspects.on Sarasa do
                          where name(/fo{2}/)
                        end)

      expect(name_condition).to eq([:foo])
    end

    it 'should get foo method (match with both regexps)' do
      name_condition = (Aspects.on Sarasa do
                          where name(/fo{2}/), name(/foo/)
                        end)

      expect(name_condition).to eq([:foo])
    end

    it 'should get empty array (no method match with regexp)' do
      name_condition = (Aspects.on Sarasa do
                          where name(/^fi+/)
                        end)

      expect(name_condition).to eq([])
    end

    it 'should get empty array (no method match with both regexp)' do
      name_condition = (Aspects.on Sarasa do
                          where name(/foo/), name(/bar/)
                        end)

      expect(name_condition).to eq([])
    end

  end

  context 'Visibility Condition' do

    it 'should get bar method ( bar is private)' do
      private_condition = (Aspects.on TestClass do
                            where name(/bar/), is_private
                          end)

      expect(private_condition).to eq([:bar])
    end

    it 'should get empty array (bar is not public)' do
      public_condition = (Aspects.on TestClass do
                            where name(/bar/), is_public
                          end)

      expect(public_condition).to eq([])
    end

  end

  context 'Parameters Count Condition' do

    it 'should get foo method (has three mandatory parameters)' do
      three_mandatory_condition = (Aspects.on Sarasa do
                                     where has_parameters(3, mandatory)
                                  end)

      expect(three_mandatory_condition).to eq([:foo])
    end

    it 'should get foo method (has six parameters)' do
      six_parammeters_condition = (Aspects.on Sarasa do
                                    where has_parameters(6)
                                  end)

      expect(six_parammeters_condition).to eq([:foo])
    end

    it 'should get foo and bar method (both have three optional parameters)' do
      three_optional_condition = (Aspects.on Sarasa do
                                    where has_parameters(3, optional)
                                  end)

      expect(three_optional_condition).to eq([:foo, :bar])
    end

  end

  context 'Parameters Name Condition' do

    it 'should get bar method (has 1 parameter with param in the name)' do
      one_parameter_with_param = (Aspects.on Marasa do
                                    where has_parameters(1, /param.*/)
                                  end)

      expect(one_parameter_with_param).to eq([:bar])
    end

    it 'should get foo method (has 2 parameters with param in the name)' do
      two_parameter_with_param = (Aspects.on Marasa do
                                    where has_parameters(2, /param.*/)
                                  end)

      expect(two_parameter_with_param).to eq([:foo])
    end

    it 'should get empty array (nobody has 3 parameters with param in the name)' do
      three_parameter_with_param = (Aspects.on Marasa do
                                      where has_parameters(3, /param.*/)
                                    end)

      expect(three_parameter_with_param).to eq([])
    end

    it 'should get empty array (nobody has 2 parameters with param2.* in the name)' do
      methods = (Aspects.on Marasa do
        where has_parameters(2, /param2.*/)
      end)

      expect(methods).to eq([])
    end

  end

 context 'Neg Condition' do

   it 'should get foo2 and foo3 (both do not have 1 parameter)' do
     neg_condition = (Aspects.on TestModule do
                       where name(/foo\d/), neg(has_parameters(1), name(/foo2/))
                     end)

     expect(neg_condition).to eq([:foo3])
   end

 end

end