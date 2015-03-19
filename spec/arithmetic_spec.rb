require 'rspec'
require_relative '../lib/push-forth'
include PushForth

describe "add" do
  it "should be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:add)).to be true
  end

  it "should disappear if there are not two args" do
    expect(PushForthInterpreter.new([[:add]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:add],1]).step!.stack).to eq [[],1]
  end

  it "should return the sum if there are two Numerics there" do
    expect(PushForthInterpreter.new([[:add],1,2]).step!.stack).to eq [[],3]
    expect(PushForthInterpreter.new([[:add],Rational("1/4"),Complex(-4,1)]).step!.stack).to eq [[],Complex(Rational("-15/4"),1)]
  end

  it "should build a continuation if either of the args isn't Numeric" do
    expect(PushForthInterpreter.new([[:add],"a",2,3]).step!.stack).to eq [[:add,"a"],2,3]
    expect(PushForthInterpreter.new([[:add],2,"b",3]).step!.stack).to eq [[:add,"b"],2,3]
  end

  it "should work when the code stack is populated" do
    expect(PushForthInterpreter.new([[:add,1,2],"a",3,4]).step!.stack).
      to eq [[:add,"a",1,2],3,4]
    expect(PushForthInterpreter.new([[:add,1,2],3,"a",4]).step!.stack).
      to eq [[:add,"a",1,2],3,4]
  end
end


describe "subtract" do
  it "should be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:subtract)).to be true
  end

  it "should disappear if there are not two args" do
    expect(PushForthInterpreter.new([[:subtract]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:subtract],1]).step!.stack).to eq [[],1]
  end

  it "should return the difference if there are two Numerics there" do
    expect(PushForthInterpreter.new([[:subtract],3,5]).step!.stack).to eq [[],-2]
    expect(PushForthInterpreter.new([[:subtract],Rational("1/4"),Complex(-4,1)]).step!.stack).to eq [[],Complex(Rational("17/4"),-1)] # ((17/4)-1i)
  end

  it "should build a continuation if either of the args isn't Numeric" do
    skipA = PushForthInterpreter.new([[:subtract],"a",5,9])
    expect(skipA.step!.stack).to eq [[:subtract,"a"],5,9]
    expect(skipA.step!.stack).to eq [["a"],-4]
    skipB = PushForthInterpreter.new([[:subtract],5,"b",9])
    expect(skipB.step!.stack).to eq [[:subtract,"b"],5,9]
    expect(skipB.step!.stack).to eq [["b"],-4]
  end
end


describe "multiply" do
  it "should be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:multiply)).to be true
  end

  it "should disappear if there are not two args" do
    expect(PushForthInterpreter.new([[:multiply]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:multiply],1]).step!.stack).to eq [[],1]
  end

  it "should return the product if there are two Numerics there" do
    expect(PushForthInterpreter.new([[:multiply],3,5]).step!.stack).to eq [[],15]
    expect(PushForthInterpreter.new([[:multiply],Rational("1/4"),Complex(-4,1)]).step!.stack).to eq [[],Complex(Rational("-1/1"),Rational("1/4"))] # ((-1/1)+(1/4)*i)
  end

  it "should build a continuation if either of the args isn't Numeric" do
    skipA = PushForthInterpreter.new([[:multiply],"a",5,9])
    expect(skipA.step!.stack).to eq [[:multiply,"a"],5,9]
    expect(skipA.step!.stack).to eq [["a"],45]
    skipB = PushForthInterpreter.new([[:multiply],5,"b",9])
    expect(skipB.step!.stack).to eq [[:multiply,"b"],5,9]
    expect(skipB.step!.stack).to eq [["b"],45]
  end
end



describe "divide" do
  it "should be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:divide)).to be true
  end

  it "should disappear if there are not two args" do
    expect(PushForthInterpreter.new([[:divide]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:divide],1]).step!.stack).to eq [[],1]
  end

  it "should return the quotient if there are two Numerics there" do
    expect(PushForthInterpreter.new([[:divide],3,5.0]).step!.stack).to eq [[],0.6]
    expect(PushForthInterpreter.new([[:divide],Rational("1/4"),Complex(-4,1)]).step!.stack).to eq [[],Complex(Rational("-1/17"),Rational("-1/68"))] # ((-1/17)-(1/68)*i)
  end

  it "should build a continuation if either of the args isn't Numeric" do
    skipA = PushForthInterpreter.new([[:divide],"a",5,10.0])
    expect(skipA.step!.stack).to eq [[:divide,"a"],5,10.0]
    expect(skipA.step!.stack).to eq [["a"],0.5]
    skipB = PushForthInterpreter.new([[:divide],20.0,"b",5.0])
    expect(skipB.step!.stack).to eq [[:divide,"b"],20.0,5.0]
    expect(skipB.step!.stack).to eq [["b"],4.0]
  end

  it "should return an Error if the denominator is 0" do
    div0 = PushForthInterpreter.new([[:divide],5,0.0]).step!()
    expect(div0.stack.length).to be 2
    expect(div0.stack[-1]).to be_a_kind_of(Error)
  end
end


describe "divmod" do
  it "should be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:divmod)).to be true
  end

  it "should disappear if there are not two args" do
    expect(PushForthInterpreter.new([[:divmod]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:divmod],1]).step!.stack).to eq [[],1]
  end

  it "should return the divmod list if there are two Numerics there" do
    expect(PushForthInterpreter.new([[:divmod],9.4,5.9]).step!.stack).to eq [[],[1, 3.5]]
    expect(PushForthInterpreter.new([[:divmod],Rational("-21/4"),Rational("11/3")]).step!.stack).to eq [[], [-2, (Rational("25/12"))]]
  end

  it "should build a continuation if either of the args isn't Numeric" do
    skipA = PushForthInterpreter.new([[:divmod],"a",5,10.0])
    expect(skipA.step!.stack).to eq [[:divmod,"a"],5,10.0]
    expect(skipA.step!.stack).to eq [["a"], [0, 5.0]]
    skipB = PushForthInterpreter.new([[:divmod],20.0,"b",5.0])
    expect(skipB.step!.stack).to eq [[:divmod,"b"],20.0,5.0]
    expect(skipB.step!.stack).to eq [["b"], [4, 0.0]]
  end

  it "should return an Error if the denominator is 0" do
    div0 = PushForthInterpreter.new([[:divmod],5,0.0]).step!()
    expect(div0.stack.length).to be 2
    expect(div0.stack[-1]).to be_a_kind_of(Error)
  end

  it "should return an Error if the denominator is Complex" do
    div0 = PushForthInterpreter.new([[:divmod],5,Complex(1,2)]).step!()
    expect(div0.stack.length).to be 2
    expect(div0.stack[-1]).to be_a_kind_of(Error)
  end
end
