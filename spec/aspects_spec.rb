require 'rspec'
require_relative '../src/aspects.rb'
require_relative 'test_classes.rb'

describe 'probando que busque bien los origenes' do

  let(:sarasa) { Sarasa.new }
  let(:objectB) { B.new }

  it 'should get objects' do
    expect(Aspects.find_origins sarasa, objectB).to eq [sarasa, objectB]
  end

  it 'should get classes' do
    expect(Aspects.find_origins Sarasa, Object, B, BasicObject, Object).to eq [Sarasa, Object, B, BasicObject]
  end


  it 'should get modules' do
    expect(Aspects.find_origins Marasa,D).to eq [Marasa,D]
  end

  it 'should get the classes and modules from the regexps' do
    expect(Aspects.find_origins /^Ob.*/, /.*rasa/).to eq [Object, ObjectSpace, Sarasa, Marasa]
  end

  it 'should get classes and modules and objects without repeated elements' do
    expect(Aspects.find_origins Sarasa, /^Ob.*/, objectB, B, /.*rasa/, sarasa, D).to eq [Sarasa,  Object, ObjectSpace, objectB, B, Marasa, sarasa, D]
    # El expect de la segunda forma
    # expect(Aspects.find_origins Sarasa, /^Ob.*/, objectB, B, /.*rasa/, sarasa, D).to eq [Sarasa, objectB, B, sarasa, D, Object, ObjectSpace, MSarasa]
  end

  it 'should raise Error: Empty Origin' do
    expect { Aspects.find_origins }.to raise_error(RuntimeError, 'Error: Empty Origin')
  end

end