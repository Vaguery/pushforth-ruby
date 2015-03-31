require 'spec_helper'

  describe "type conversions" do
    describe ":become instruction" do
      it "should be a recognized instruction" do
        expect(PushForthInterpreter.new.instruction?(:become)).to be true
      end

      it "should disappear without any args" do
        expect(PushForthInterpreter.new([[:become]]).step!.stack).to eq [[]]
      end

      it "do nothing if arg1 can't be converted" do
        # ErrorType
        starting_stack = [[:become],Error.new("foo"),:UnknownType]
        expect(PushForthInterpreter.new(starting_stack).step!.stack[1].string).
          to eq "foo"
        # InstructionType
        starting_stack = [[:become],:add,:UnknownType]
        expect(PushForthInterpreter.new(starting_stack).step!.stack[1]).
          to eq :add
        # TypeType
        starting_stack = [[:become],:ErrorType,:UnknownType]
        expect(PushForthInterpreter.new(starting_stack).step!.stack[1]).
          to eq :ErrorType
      end

      it "should return arg1 if it's already the specified type" do
        starting_stack = [[:become],false,:BooleanType]
        expect(PushForthInterpreter.new(starting_stack).step!.stack).
          to eq [[], false]
      end

      it "should call the appropriate item in @@type_conversions otherwise" do
        starting_stack = [[:become],false,:FloatType]
        expect(PushForthInterpreter.new(starting_stack).step!.stack).
          to eq [[], -1.0]
      end
    end
  end

  # [:BooleanType, :ComplexType, :DictionaryType, :ErrorType, :FloatType, :InstructionType, :IntegerType, :ListType, :NumberType, :RationalType, :TypeType, :UnknownType]

  # the only "convertible" types are: Boolean, Complex, Dictionary, Float, Integer, List, Rational
  # the "unconvertible" types are: Error, Instruction, Number, Type, Unknown
  # nothing converts into an Error, Instruction, Number, Type or Unknown

describe "type conversions" do

  # Boolean -> Complex
  it "should make a Boolean into a 1+1i or -1-1i, respectively" do
    expect(PushForthInterpreter.new([[:become],true,:ComplexType]).step!.stack).
      to eq [[], Complex(1,1)]
    expect(PushForthInterpreter.new([[:become],false,:ComplexType]).step!.stack).
      to eq [[], Complex(-1,-1)]
  end

  # Boolean -> Dictionary
  it "should make a Boolean into a Dictionary with k,v = arg1" do
    expect(PushForthInterpreter.new([[:become],true,:DictionaryType]).step!.stack[1].contents).
      to eq({true => true})
    expect(PushForthInterpreter.new([[:become],false,:DictionaryType]).step!.stack[1].contents).
      to eq({false => false})
  end

  # Boolean -> Float
  # Boolean -> Integer
  # Boolean -> List
  # Boolean -> Rational
  # 
  # Complex -> Boolean
  # Complex -> Dictionary
  # Complex -> Float  
  # Complex -> Integer
  # Complex -> List
  # Complex -> Rational
  # 
  # Dictionary -> Boolean
  # Dictionary -> Complex
  # Dictionary -> Float
  # Dictionary -> Integer
  # Dictionary -> List
  # Dictionary -> Rational
  #
  # Float -> Boolean
  # Float -> Complex
  # Float -> Dictionary
  # Float -> Integer
  # Float -> List
  # Float -> Rational
  #
  # Integer -> Boolean
  # Integer -> Complex
  # Integer -> Dictionary
  # Integer -> Float
  # Integer -> Integer
  # Integer -> List
  # Integer -> Rational
  #
  # List -> Boolean
  # List -> Complex
  # List -> Dictionary
  # List -> Float
  # List -> Integer
  # List -> Rational
  #
  # Rational -> Boolean
  # Rational -> Complex
  # Rational -> Dictionary
  # Rational -> Float
  # Rational -> Integer
  # Rational -> List

end
