require 'rspec'
require_relative '../src/aspects.rb'
require_relative 'test_classes.rb'

describe 'origins find' do

  let(:sarasa) { Sarasa.new }
  let(:object_b) { TestClass.new }

  it 'should get objects' do
    expect(Aspects.find_origins sarasa, object_b).to eq [sarasa, object_b]
  end

  it 'should get classes' do
    expect(Aspects.find_origins Sarasa, Object, TestClass, BasicObject, Object).to eq [Sarasa, Object, TestClass, BasicObject]
  end


  it 'should get modules' do
    expect(Aspects.find_origins Marasa,AnotherTestClass).to eq [Marasa,AnotherTestClass]
  end

  it 'should get the classes and modules from the regexps' do
    expect(Aspects.find_origins /^Ob.*/, /.*rasa/).to eq [Object, ObjectSpace, Sarasa, Marasa]
  end

  it 'should get classes and modules and objects without repeated elements' do
    expect(Aspects.find_origins Sarasa, /^Ob.*/, object_b, TestClass, /.*rasa/, sarasa, AnotherTestClass).to eq [Sarasa,  Object, ObjectSpace, object_b, TestClass, Marasa, sarasa, AnotherTestClass]
  end

  it 'should raise Error: Empty Origin' do
    expect { Aspects.find_origins }.to raise_error(RuntimeError, 'Error: Empty Origin')
  end

end