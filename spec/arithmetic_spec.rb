require 'rspec'
require_relative '../lib/push-forth'

describe "add" do
  it "be a recognized instruction" do
    expect(PushForth.new.instruction?(:add)).to be true
  end

  it "should disappear if there are not two args" do
    expect(PushForth.new([[:add]]).step!.stack).to eq [[]]
    expect(PushForth.new([[:add],1]).step!.stack).to eq [[],1]
  end

  it "should return the sum if there are two Numerics there" do
    expect(PushForth.new([[:add],1,2]).step!.stack).to eq [[],3]
    expect(PushForth.new([[:add],Rational("1/4"),Complex(-4,1)]).step!.stack).to eq [[],Complex(Rational("-15/4"),1)]
  end

  it "should build a continuation if either of the args isn't Numeric" do
    expect(PushForth.new([[:add],"a",2,3]).step!.stack).to eq [[:add,"a"],2,3]
    expect(PushForth.new([[:add],2,"b",3]).step!.stack).to eq [[:add,"b"],2,3]
  end

  it "should work when the code stack is populated" do
    expect(PushForth.new([[:add,1,2],"a",3,4]).step!.stack).
      to eq [[:add,"a",1,2],3,4]
    expect(PushForth.new([[:add,1,2],3,"a",4]).step!.stack).
      to eq [[:add,"a",1,2],3,4]
  end
end


describe "subtract" do
  it "be a recognized instruction" do
    expect(PushForth.new.instruction?(:subtract)).to be true
  end

  it "should disappear if there are not two args" do
    expect(PushForth.new([[:subtract]]).step!.stack).to eq [[]]
    expect(PushForth.new([[:subtract],1]).step!.stack).to eq [[],1]
  end

  it "should return the difference if there are two Numerics there" do
    expect(PushForth.new([[:subtract],3,5]).step!.stack).to eq [[],-2]
    expect(PushForth.new([[:subtract],Rational("1/4"),Complex(-4,1)]).step!.stack).to eq [[],Complex(Rational("17/4"),-1)] # ((17/4)-1i)
  end

  it "should build a continuation if either of the args isn't Numeric" do
    skipA = PushForth.new([[:subtract],"a",5,9])
    expect(skipA.step!.stack).to eq [[:subtract,"a"],5,9]
    expect(skipA.step!.stack).to eq [["a"],-4]
    skipB = PushForth.new([[:subtract],5,"b",9])
    expect(skipB.step!.stack).to eq [[:subtract,"b"],5,9]
    expect(skipB.step!.stack).to eq [["b"],-4]
  end
end


describe "multiply" do
  it "be a recognized instruction" do
    expect(PushForth.new.instruction?(:multiply)).to be true
  end

  it "should disappear if there are not two args" do
    expect(PushForth.new([[:multiply]]).step!.stack).to eq [[]]
    expect(PushForth.new([[:multiply],1]).step!.stack).to eq [[],1]
  end

  it "should return the product if there are two Numerics there" do
    expect(PushForth.new([[:multiply],3,5]).step!.stack).to eq [[],15]
    expect(PushForth.new([[:multiply],Rational("1/4"),Complex(-4,1)]).step!.stack).to eq [[],Complex(Rational("-1/1"),Rational("1/4"))] # ((-1/1)+(1/4)*i)
  end

  it "should build a continuation if either of the args isn't Numeric" do
    skipA = PushForth.new([[:multiply],"a",5,9])
    expect(skipA.step!.stack).to eq [[:multiply,"a"],5,9]
    expect(skipA.step!.stack).to eq [["a"],45]
    skipB = PushForth.new([[:multiply],5,"b",9])
    expect(skipB.step!.stack).to eq [[:multiply,"b"],5,9]
    expect(skipB.step!.stack).to eq [["b"],45]
  end
end



describe "divide" do
  it "be a recognized instruction" do
    expect(PushForth.new.instruction?(:divide)).to be true
  end

  it "should disappear if there are not two args" do
    expect(PushForth.new([[:divide]]).step!.stack).to eq [[]]
    expect(PushForth.new([[:divide],1]).step!.stack).to eq [[],1]
  end

  it "should return the quotient if there are two Numerics there" do
    expect(PushForth.new([[:divide],3,5.0]).step!.stack).to eq [[],0.6]
    expect(PushForth.new([[:divide],Rational("1/4"),Complex(-4,1)]).step!.stack).to eq [[],Complex(Rational("-1/17"),Rational("-1/68"))] # ((-1/17)-(1/68)*i)
  end

  it "should build a continuation if either of the args isn't Numeric" do
    skipA = PushForth.new([[:divide],"a",5,10.0])
    expect(skipA.step!.stack).to eq [[:divide,"a"],5,10.0]
    expect(skipA.step!.stack).to eq [["a"],0.5]
    skipB = PushForth.new([[:divide],20.0,"b",5.0])
    expect(skipB.step!.stack).to eq [[:divide,"b"],20.0,5.0]
    expect(skipB.step!.stack).to eq [["b"],4.0]
  end

  it "should return an Error if the denominator is 0" do
    div0 = PushForth.new([[:divide],5,0.0]).step!()
    expect(div0.stack.length).to be 2
    expect(div0.stack[-1]).to be_a_kind_of(Error)
  end
end
