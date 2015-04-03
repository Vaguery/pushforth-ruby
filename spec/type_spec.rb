require 'spec_helper'

describe ":type instruction" do
  it "should be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:type)).to be true
  end

  it "should disappear if there isn't an arg" do
    expect(PushForthInterpreter.new([[:type]]).step!.stack).to eq [[]]
  end

  it "should recognize numbers" do
    expect(PushForthInterpreter.new([[:type],8]).step!.stack).to eq [[],:IntegerType]
    expect(PushForthInterpreter.new([[:type],0.8]).step!.stack).to eq [[],:FloatType]
    expect(PushForthInterpreter.new([[:type],Rational("1/4")]).step!.stack).to eq [[],:RationalType]
    expect(PushForthInterpreter.new([[:type],3+1i]).step!.stack).to eq [[],:ComplexType]
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

  it "should recognize Ranges" do
    expect(PushForthInterpreter.new([[:type],(8..99)]).step!.stack).to eq [[],:RangeType]
  end
end

describe ":types instruction" do
  it "should be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:types)).to be true
  end

  it "should disappear if there isn't an arg" do
    expect(PushForthInterpreter.new([[:types]]).step!.stack).to eq [[]]
  end

  it "should return a List containing the type of a root-typed item" do
    expect(PushForthInterpreter.new([[:types],Dictionary.new()]).step!.stack).to eq [[],[:DictionaryType]]
  end

  it "should recognize numbers" do
    expect(PushForthInterpreter.new([[:types],8]).step!.stack).to eq [[],[:IntegerType, :NumberType]]
    expect(PushForthInterpreter.new([[:types],0.8]).step!.stack).to eq [[],[:FloatType, :NumberType]]
    expect(PushForthInterpreter.new([[:types],Rational("1/4")]).step!.stack).to eq [[], [:RationalType, :NumberType]]
    expect(PushForthInterpreter.new([[:types],3+1i]).step!.stack).to eq [[], [:ComplexType, :NumberType]]
  end

  it "should recognize a Range" do
    expect(PushForthInterpreter.new([[:types],(1.2..2.8)]).step!.stack).to eq [[],[:RangeType]]
  end
end

describe ":is_a? instruction" do
  it "should be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:is_a?)).to be true
  end

  it "should disappear if there aren't two arguments" do
    expect(PushForthInterpreter.new([[:is_a?]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:is_a?],77]).step!.stack).to eq [[],77]
  end

  it "should return take a Type and anything args, and return a bool 'is arg2 type arg1?'" do
    expect(PushForthInterpreter.new([[:is_a?],:NumberType,77]).step!.stack).to eq [[],true]
    expect(PushForthInterpreter.new([[:is_a?],:NumberType,false]).step!.stack).to eq [[],false]
    expect(PushForthInterpreter.new([[:is_a?],:IntegerType,77]).step!.stack).to eq [[],true]
    expect(PushForthInterpreter.new([[:is_a?],:IntegerType,77.7]).step!.stack).to eq [[],false]
  end

  it "should use a continuation if the first arg isn't a Type" do
    expect(PushForthInterpreter.new([[:is_a?],false,77]).step!.stack).
      to eq [[:is_a?,false],77]
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

  it "should know about nested types" do
    expect(PushForthInterpreter.new([[:gather_all],:FloatType,[1,2],3.9,4]).step!.stack).
      to eq [[], [3.9], [1, 2], 4]
    expect(PushForthInterpreter.new([[:gather_all],:NumberType,[1,2],3.9,4]).step!.stack).
      to eq [[], [3.9, 4], [1, 2]]
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

  it "should work at the most specific level when dealing with subtypes" do
    expect(PushForthInterpreter.new([[:gather_same],88.2,1,2.9,3.9,4]).step!.stack).
      to eq [[], [88.2, 2.9, 3.9], 1, 4]
  end
end

