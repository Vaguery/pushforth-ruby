require 'rspec'
require_relative '../lib/push-forth'
include PushForth

# PushForth::Type: Number, Boolean, Dictionary, Error, List, Symbol, Type

describe ":type instruction" do
  it "should be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:type)).to be true
  end

  it "should disappear if there isn't an arg" do
    expect(PushForthInterpreter.new([[:type]]).step!.stack).to eq [[]]
  end

  it "should recognize numbers" do
    expect(PushForthInterpreter.new([[:type],8]).step!.stack).to eq [[],:NumberType]
    expect(PushForthInterpreter.new([[:type],0.8]).step!.stack).to eq [[],:NumberType]
    expect(PushForthInterpreter.new([[:type],Rational("1/4")]).step!.stack).to eq [[],:NumberType]
    expect(PushForthInterpreter.new([[:type],Complex(3,1)]).step!.stack).to eq [[],:NumberType]
  end

  it "should recognize booleans" do
    expect(PushForthInterpreter.new([[:type],false]).step!.stack).to eq [[],:BooleanType]
    expect(PushForthInterpreter.new([[:type],true]).step!.stack).to eq [[],:BooleanType]
  end

  it "should recognize Lists" do
    expect(PushForthInterpreter.new([[:type],[]]).step!.stack).to eq [[],:ListType]
    expect(PushForthInterpreter.new([[:type],[1,2,3]]).step!.stack).to eq [[],:ListType]
  end

  it "should recognize Dictionary items" do
    expect(PushForthInterpreter.new([[:type],Dictionary.new()]).step!.stack).to eq [[],:DictionaryType]
  end

  it "should recognize instructions" do
    expect(PushForthInterpreter.new([[:type],:enlist]).step!.stack).to eq [[],:InstructionType]
  end

  it "should not recognize weird instructions" do
    expect(PushForthInterpreter.new([[:type],:foo]).step!.stack).to eq [[],:UnknownType]
  end

  it "should recognize Types" do
    expect(PushForthInterpreter.new([[:type],:UnknownType]).step!.stack).to eq [[],:TypeType]
  end


end