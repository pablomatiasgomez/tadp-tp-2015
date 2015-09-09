require 'rspec'
require_relative '../src/aspects.rb'
require_relative 'test_classes.rb'

describe 'Origins conditions' do

  let(:object_instance_methods) {Object.instance_methods+Object.private_instance_methods}

  let(:no_condition) {
    (Aspects.on Object do
      where
    end).map { |_, m| m}
  }

  let(:name_condition) {
    (Aspects.on Object do
      where name(/^a.*/)
    end).map { |_, m| m}
  }

  let(:public_condition) {
    (Aspects.on Object do
      where is_public
    end).map { |_, m| m}
  }

  let(:private_condition) {
    (Aspects.on Object do
      where is_private
    end).map { |_, m| m}
  }

  let(:six_parammeters_condition) {
    (Aspects.on Sarasa do
      where has_parameters(6)
    end).map { |_, m| m}
  }

  let(:three_mandatory_condition) {
    (Aspects.on Sarasa do
      where has_parameters(3, mandatory)
    end).map { |_, m| m}
  }

  let(:three_optional_condition) {
    (Aspects.on Sarasa do
      where has_parameters(3, optional)
    end).map { |_, m| m}
  }

  it 'should get the instance methods of Object' do
    expect(no_condition).to eq(object_instance_methods)
  end

  it 'should get the instance methods of Object beginning with a' do
    expect(name_condition).to eq(object_instance_methods.grep(/^a.*/))
  end

  it 'should get the instance public methods of Object' do
    expect(public_condition).to eq(Object.public_instance_methods)
  end

  it 'should get the instance private methods of Object' do
    expect(private_condition).to eq(Object.private_instance_methods)
  end

  it 'should get foo method from Sarasa' do
    expect(six_parammeters_condition).to eq([:foo])
  end

  it 'should get foo method from Sarasa' do
    expect(three_mandatory_condition).to eq([:foo])
  end

  it 'should get foo and bar method from Sarasa' do
    expect(three_optional_condition).to eq([:foo, :bar])
  end

end