require 'rspec'
require_relative '../src/aspects.rb'

describe 'Origins conditions' do

  let(:an_object) {Object.new}

  let(:noCondition) {
    (Aspects.on Object do
      where
    end).map { |_, m| m}
  }

  let(:nameCondition) {
    (Aspects.on Object do
      where name(/^a.*/)
    end).map { |_, m| m}
  }

  it 'should get the instance methods of Object' do
    expect(noCondition).to eq(Object.instance_methods)
    expect(noCondition).to eq(an_object.methods)
  end

  it 'should get the instnce methods of Object beginning with a' do
    expect(nameCondition).to eq(Object.instance_methods.grep(/^a.*/))
    expect(nameCondition).to eq(an_object.methods.grep(/^a.*/))
  end

end