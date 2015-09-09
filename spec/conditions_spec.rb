require 'rspec'
require_relative '../src/aspects.rb'

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

end