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

      it "should return an Error if it doesn't have a converter" do
        starting_stack = [[:become],false,:UnknownType]
        expect(PushForthInterpreter.new(starting_stack).step!.stack[1]).
          to be_a_kind_of(Error)
      end

      it "should build a continuation if the second arg isn't a Type" do
        starting_stack = [[:become],false,33]
        expect(PushForthInterpreter.new(starting_stack).step!.stack).
          to eq [[:become, 33],false]
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
  it "should make a Boolean into a 1.0 or -1.0, respectively" do
    expect(PushForthInterpreter.new([[:become],true,:FloatType]).step!.stack).
      to eq [[], 1.0]
    expect(PushForthInterpreter.new([[:become],false,:FloatType]).step!.stack).
      to eq [[], -1.0]
  end

  # Boolean -> Integer
  it "should make a Boolean into a 1 or -1, respectively" do
    expect(PushForthInterpreter.new([[:become],true,:IntegerType]).step!.stack).
      to eq [[], 1]
    expect(PushForthInterpreter.new([[:become],false,:IntegerType]).step!.stack).
      to eq [[], -1]
  end

  # Boolean -> List
  it "should make a Boolean into a [true] or [false], respectively" do
    expect(PushForthInterpreter.new([[:become],true,:ListType]).step!.stack).
      to eq [[], [true]]
    expect(PushForthInterpreter.new([[:become],false,:ListType]).step!.stack).
      to eq [[], [false]]
  end

  # Boolean -> Rational
  it "should make a Boolean into a 1 or -1, respectively" do
    expect(PushForthInterpreter.new([[:become],true,:RationalType]).step!.stack).
      to eq [[], Rational("1/1")]
    expect(PushForthInterpreter.new([[:become],false,:RationalType]).step!.stack).
      to eq [[], Rational("-1/1")]
  end

  # 
  # Complex -> Boolean
  it "should make a Complex into a true or false by inverting the relation" do
    expect(PushForthInterpreter.new([[:become],Complex(5,2),:BooleanType]).step!.stack).
      to eq [[], true]
    expect(PushForthInterpreter.new([[:become],Complex(-5,-2),:BooleanType]).step!.stack).
      to eq [[], false]
    expect(PushForthInterpreter.new([[:become],Complex(-5,2),:BooleanType]).step!.stack).
      to eq [[], false]
    expect(PushForthInterpreter.new([[:become],Complex(5,-2),:BooleanType]).step!.stack).
      to eq [[], true]
    expect(PushForthInterpreter.new([[:become],Complex(-5,0),:BooleanType]).step!.stack).
      to eq [[], false]
    expect(PushForthInterpreter.new([[:become],Complex(5,0),:BooleanType]).step!.stack).
      to eq [[], true]
  end

  # Complex -> Dictionary
  it "should make a Complex into a Dictionary with k,v = arg1" do
    expect(PushForthInterpreter.new([[:become],Complex(1,2),:DictionaryType]).step!.stack[1].contents).to eq({Complex(1,2) => Complex(1,2)})
  end

  # Complex -> Float 
  it "should make a Complex into two Floats" do
    expect(PushForthInterpreter.new([[:become],Complex(1,2),:FloatType]).step!.stack).
      to eq [[],[1.0,2.0]]
  end

  # Complex -> Integer
  it "should make a Complex into two Floats" do
    expect(PushForthInterpreter.new([[:become],Complex(1,2),:IntegerType]).step!.stack).
      to eq [[],[1,2]]
  end

  # Complex -> List
  it "should wrap itself into a List" do
    expect(PushForthInterpreter.new([[:become],Complex(1,2),:ListType]).step!.stack).
      to eq [[],[Complex(1,2)]]
  end

  # Complex -> Rational
  it "should make a Complex into two Rationals (using #to_r)" do
    expect(PushForthInterpreter.new([[:become],Complex(1,2),:RationalType]).step!.stack).
      to eq [[],[Rational("1/1"),Rational("2/1")]]
    expect(PushForthInterpreter.new([[:become],Complex(-0.25,2.5),:RationalType]).step!.stack).
      to eq [[], [Rational("-1/4"), Rational("5/2")]]
  end

  # 
  # Dictionary -> Boolean; Dictionary -> Complex; Dictionary -> Float; Dictionary -> Integer
  #   let it fail

  # Dictionary -> List
  it "should make a Dictionary into a List of key-value pairs, flattened" do
    d = Dictionary.new({1 => 2, false => [11,22,33], "foo" => :BooleanType})
    expect(PushForthInterpreter.new([[:become],d,:ListType]).step!.stack).
      to eq [[], [1, 2, false, [11, 22, 33], "foo", :BooleanType]]
    expect(PushForthInterpreter.new([[:become],Dictionary.new(),:ListType]).step!.stack).
      to eq [[],[]]
  end

  # Dictionary -> Rational
  #   let it fail

  # Float -> Boolean
  it "should make a Float into a true or false by inverting the relation" do
    expect(PushForthInterpreter.new([[:become],99.1,:BooleanType]).step!.stack).
      to eq [[], true]
    expect(PushForthInterpreter.new([[:become],-99.1,:BooleanType]).step!.stack).
      to eq [[], false]
    expect(PushForthInterpreter.new([[:become],0.0,:BooleanType]).step!.stack).
      to eq [[], false]
  end

  # Float -> Complex
  it "should make a Float into a Complex by adding 0i" do
    expect(PushForthInterpreter.new([[:become],99.1,:ComplexType]).step!.stack).
      to eq [[], Complex(99.1,0.0)]
    expect(PushForthInterpreter.new([[:become],-99.1,:ComplexType]).step!.stack).
      to eq [[], Complex(-99.1,0.0)]
    expect(PushForthInterpreter.new([[:become],0.0,:ComplexType]).step!.stack).
      to eq [[], Complex(0.0,0.0)]
  end

  # Float -> Dictionary
  it "should make a Float into a Dictionary with k,v = arg1" do
    expect(PushForthInterpreter.new([[:become],123.45,:DictionaryType]).step!.stack[1].contents).to eq({123.45 => 123.45})
  end

  # Float -> Integer
  it "should use the .to_i method" do
    expect(PushForthInterpreter.new([[:become],123.45,:IntegerType]).step!.stack).to eq [[],123]
  end

  # Float -> List
  it "should wrap itself into a List" do
    expect(PushForthInterpreter.new([[:become],771.25,:ListType]).step!.stack).
      to eq [[],[771.25]]
  end

  # Float -> Rational
  it "should use the .to_r method" do
    expect(PushForthInterpreter.new([[:become],771.25,:RationalType]).step!.stack).
      to eq [[], Rational("3085/4")]
    expect(PushForthInterpreter.new([[:become],-0.0,:RationalType]).step!.stack).
      to eq [[], Rational("0/1")]
  end

  #
  # Integer -> Boolean
  it "should make an Integer into a true or false by inverting the relation" do
    expect(PushForthInterpreter.new([[:become],99,:BooleanType]).step!.stack).
      to eq [[], true]
    expect(PushForthInterpreter.new([[:become],-99,:BooleanType]).step!.stack).
      to eq [[], false]
    expect(PushForthInterpreter.new([[:become],0,:BooleanType]).step!.stack).
      to eq [[], false]
  end

  # Integer -> Complex
  it "should make an Integer into a Complex by adding 0i" do
    expect(PushForthInterpreter.new([[:become],99,:ComplexType]).step!.stack).
      to eq [[], Complex(99,0)]
    expect(PushForthInterpreter.new([[:become],-99,:ComplexType]).step!.stack).
      to eq [[], Complex(-99,0)]
    expect(PushForthInterpreter.new([[:become],0,:ComplexType]).step!.stack).
      to eq [[], Complex(0,0)]
  end

  # Integer -> Dictionary
  it "should make an Integer into a Dictionary with k,v = arg1" do
    expect(PushForthInterpreter.new([[:become],123,:DictionaryType]).step!.stack[1].contents).to eq({123 => 123})
  end

  # Integer -> Float
  it "should use the .to_f method" do
    expect(PushForthInterpreter.new([[:become],123,:FloatType]).step!.stack[1]).to be 123.0
  end

  # Integer -> List
  it "should wrap itself into a List" do
    expect(PushForthInterpreter.new([[:become],300,:ListType]).step!.stack).
      to eq [[],[300]]
  end

  # Integer -> Rational
  it "should use the .to_r method" do
    expect(PushForthInterpreter.new([[:become],123,:RationalType]).step!.stack).
      to eq [[], (123/1)]
  end

  #
  # List -> Boolean; List -> Complex; List -> Float; List -> Integer; List -> Rational
    #   let it fail

  # List -> Dictionary
  it "should build a Dictionary using pairs of elements as k,v" do
    expect(PushForthInterpreter.new([[:become],[1,2,3,4,5,6],:DictionaryType]).
      step!.stack[1].contents).to eq({1=>2, 3=>4, 5=>6})
    expect(PushForthInterpreter.new([[:become],[],:DictionaryType]).
      step!.stack[1].contents).to eq({})
  end

  it "should drop the last element if there are an odd number" do
    expect(PushForthInterpreter.new([[:become],[1,2,3,4,5],:DictionaryType]).
      step!.stack[1].contents).to eq({1=>2, 3=>4})
  end

  # Rational -> Boolean
  it "should be false if 0 or less" do
    expect(PushForthInterpreter.new([[:become],Rational("1/11"),:BooleanType]).
      step!.stack).to eq [[],true]
  end

  # Rational -> Complex
  it "should make a Rational into a Complex by adding 0i" do
    expect(PushForthInterpreter.new([[:become],Rational("1/4"),:ComplexType]).step!.stack).
      to eq  [[], (Rational("1/4")+0i)]
    expect(PushForthInterpreter.new([[:become],Rational("0/1"),:ComplexType]).step!.stack).
      to eq [[], (Rational("0/1")+0i)]
    expect(PushForthInterpreter.new([[:become],Rational("-2/4"),:ComplexType]).step!.stack).
      to eq [[], (Rational("-1/2")+0i)]
  end

  # Rational -> Dictionary
  it "should make a Rational into a Dictionary with k,v = arg1" do
    r = Rational("1/23")
    expect(PushForthInterpreter.new([[:become],r,:DictionaryType]).step!.stack[1].contents).to eq({r => r})
  end

  # Rational -> Float
  it "should use the .to_f method" do
    r = Rational("-1/16")
    expect(PushForthInterpreter.new([[:become],r,:FloatType]).step!.stack).to eq [[], -0.0625]
  end

  # Rational -> Integer
  it "should use the .to_i method" do
    r = Rational("-133/16")
    expect(PushForthInterpreter.new([[:become],r,:IntegerType]).step!.stack).to eq [[], -8]
  end

  # Rational -> List
  it "should wrap itself into a List" do
    r = Rational("-133/16")
    expect(PushForthInterpreter.new([[:become],r,:ListType]).step!.stack).
      to eq [[],[r]]
  end
end
