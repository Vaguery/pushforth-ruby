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

describe ":gather_all instruction" do
  it "should be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:gather_all)).to be true
  end

  it "should disappear if there isn't an arg that's a Type" do
    expect(PushForthInterpreter.new([[:gather_all]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:gather_all],77]).step!.stack).to eq [[],77]
  end

  it "should gather all the items on the stack of the specified type" do
    expect(PushForthInterpreter.new([[:gather_all],:NumberType,1,2,3,4]).step!.stack).to eq [[],[1,2,3,4]]
    expect(PushForthInterpreter.new([[:gather_all],:BooleanType,1,false,3,true]).step!.stack).
      to eq [[], [false, true], 1, 3]
  end

  it "should ignore things inside Lists" do
    expect(PushForthInterpreter.new([[:gather_all],:NumberType,[1,2],3,4]).step!.stack).
      to eq [[], [3, 4], [1, 2]]
  end
end

describe ":gather_same instruction" do
  it "should be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:gather_same)).to be true
  end

  it "should disappear without an arg" do
    expect(PushForthInterpreter.new([[:gather_same]]).step!.stack).to eq [[]]
  end

  it "should gather all the items on the stack with the same type" do
    expect(PushForthInterpreter.new([[:gather_same],1,2,3,4]).step!.stack).to eq [[], [1, 2, 3, 4]]
    expect(PushForthInterpreter.new([[:gather_same],1,false,3,true]).step!.stack).
      to eq [[], [1,3], false, true]
  end

  it "should ignore things inside Lists" do
    expect(PushForthInterpreter.new([[:gather_same],88,[1,2],3,4]).step!.stack).
      to eq [[], [88, 3, 4], [1, 2]]
  end
end