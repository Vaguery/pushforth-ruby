require 'spec_helper'

describe "comparison" do
  describe ">" do
    it "should be a recognized instruction" do
      expect(PushForthInterpreter.new.instruction?(:>)).to be true
    end

    it "should disappear if there are not two Numeric args" do
      expect(PushForthInterpreter.new([[:>]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:>],1]).step!.stack).to eq [[],1]
    end

    it "should return a Boolean if there are two Numerics there" do
      expect(PushForthInterpreter.new([[:>],1,2]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:>],1,1]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:>],3,2]).step!.stack).to eq [[],true]
      expect(PushForthInterpreter.new([[:>],Rational("1/4"),0.124]).step!.stack).to eq [[],true]
    end

    it "should build a continuation if either of the args isn't Numeric" do
      expect(PushForthInterpreter.new([[:>],"a",2,3]).step!.stack).to eq [[:>,"a"],2,3]
      expect(PushForthInterpreter.new([[:>],2,"b",3]).step!.stack).to eq [[:>,"b"],2,3]
    end

    it "should work when the code stack is populated" do
      expect(PushForthInterpreter.new([[:>,1,2],"a",3,4]).step!.stack).
        to eq [[:>,"a",1,2],3,4]
      expect(PushForthInterpreter.new([[:>,1,2],3,"a",4]).step!.stack).
        to eq [[:>,"a",1,2],3,4]
    end

    it "produce an error if one of the arguments is a Complex number" do
      expect(PushForthInterpreter.new([[:>],0.25r,-4+1i]).step!.stack[-1]).to be_a_kind_of(Error)
    end
  end

  describe "<" do
    it "should be a recognized instruction" do
      expect(PushForthInterpreter.new.instruction?(:<)).to be true
    end

    it "should disappear if there are not two Numeric args" do
      expect(PushForthInterpreter.new([[:<]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:<],1]).step!.stack).to eq [[],1]
    end

    it "should return a Boolean if there are two Numerics there" do
      expect(PushForthInterpreter.new([[:<],1,2]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:<],1,1]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:<],3,2]).step!.stack).to eq [[],true]
      expect(PushForthInterpreter.new([[:<],Rational("1/4"),0.124]).step!.stack).to eq [[],true]
    end

    it "should build a continuation if either of the args isn't Numeric" do
      expect(PushForthInterpreter.new([[:<],"a",2,3]).step!.stack).to eq [[:<,"a"],2,3]
      expect(PushForthInterpreter.new([[:<],2,"b",3]).step!.stack).to eq [[:<,"b"],2,3]
    end

    it "should work when the code stack is populated" do
      expect(PushForthInterpreter.new([[:<,1,2],"a",3,4]).step!.stack).
        to eq [[:<,"a",1,2],3,4]
      expect(PushForthInterpreter.new([[:<,1,2],3,"a",4]).step!.stack).
        to eq [[:<,"a",1,2],3,4]
    end

    it "produce an error if one of the arguments is a Complex number" do
      expect(PushForthInterpreter.new([[:<],0.25r,-4+1i]).step!.stack[-1]).to be_a_kind_of(Error)
    end
  end

  describe "≥" do
    it "should be a recognized instruction" do
      expect(PushForthInterpreter.new.instruction?(:≥)).to be true
    end

    it "should disappear if there are not two Numeric args" do
      expect(PushForthInterpreter.new([[:≥]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:≥],1]).step!.stack).to eq [[],1]
    end

    it "should return a Boolean if there are two Numerics there" do
      expect(PushForthInterpreter.new([[:≥],1,2]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:≥],1,1]).step!.stack).to eq [[],true]
      expect(PushForthInterpreter.new([[:≥],3,2]).step!.stack).to eq [[],true]
      expect(PushForthInterpreter.new([[:≥],Rational("1/4"),0.124]).step!.stack).to eq [[],true]
    end

    it "should build a continuation if either of the args isn't Numeric" do
      expect(PushForthInterpreter.new([[:≥],"a",2,3]).step!.stack).to eq [[:≥,"a"],2,3]
      expect(PushForthInterpreter.new([[:≥],2,"b",3]).step!.stack).to eq [[:≥,"b"],2,3]
    end

    it "should work when the code stack is populated" do
      expect(PushForthInterpreter.new([[:≥,1,2],"a",3,4]).step!.stack).
        to eq [[:≥,"a",1,2],3,4]
      expect(PushForthInterpreter.new([[:≥,1,2],3,"a",4]).step!.stack).
        to eq [[:≥,"a",1,2],3,4]
    end

    it "produce an error if one of the arguments is a Complex number" do
      expect(PushForthInterpreter.new([[:≥],0.2r,-4+1i]).step!.stack[-1]).to be_a_kind_of(Error)
    end
  end

  describe "≤" do
    it "should be a recognized instruction" do
      expect(PushForthInterpreter.new.instruction?(:≤)).to be true
    end

    it "should disappear if there are not two Numeric args" do
      expect(PushForthInterpreter.new([[:≤]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:≤],1]).step!.stack).to eq [[],1]
    end

    it "should return a Boolean if there are two Numerics there" do
      expect(PushForthInterpreter.new([[:≤],1,2]).step!.stack).to eq [[],true]
      expect(PushForthInterpreter.new([[:≤],1,1]).step!.stack).to eq [[],true]
      expect(PushForthInterpreter.new([[:≤],3,2]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:≤],Rational("1/4"),0.124]).step!.stack).to eq [[],false]
    end

    it "should build a continuation if either of the args isn't Numeric" do
      expect(PushForthInterpreter.new([[:≤],"a",2,3]).step!.stack).to eq [[:≤,"a"],2,3]
      expect(PushForthInterpreter.new([[:≤],2,"b",3]).step!.stack).to eq [[:≤,"b"],2,3]
    end

    it "should work when the code stack is populated" do
      expect(PushForthInterpreter.new([[:≤,1,2],"a",3,4]).step!.stack).
        to eq [[:≤,"a",1,2],3,4]
      expect(PushForthInterpreter.new([[:≤,1,2],3,"a",4]).step!.stack).
        to eq [[:≤,"a",1,2],3,4]
    end

    it "produce an error if one of the arguments is a Complex number" do
      expect(PushForthInterpreter.new([[:≤],0.3r,2+2i]).step!.stack[-1]).to be_a_kind_of(Error)
    end
  end

  describe ":==" do
    it "should be a recognized instruction" do
      expect(PushForthInterpreter.new.instruction?(:==)).to be true
    end

    it "should disappear if there are not two Numeric args" do
      expect(PushForthInterpreter.new([[:==]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:==],1]).step!.stack).to eq [[],1]
    end

    it "should return a Boolean if there are two Numerics there" do
      expect(PushForthInterpreter.new([[:==],1,2]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:==],1,1]).step!.stack).to eq [[],true]
      expect(PushForthInterpreter.new([[:==],3,2]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:==],Rational("1/4"),0.124]).step!.stack).to eq [[],false]
    end

    it "should work for Complex (unlike <=> operators)" do
      expect(PushForthInterpreter.new([[:==],0.2r,3+1i]).step!.stack[-1]).to be false
    end

    it "should build a continuation if either of the args isn't Numeric" do
      expect(PushForthInterpreter.new([[:==],"a",2,3]).step!.stack).to eq [[:==,"a"],2,3]
      expect(PushForthInterpreter.new([[:==],2,"b",3]).step!.stack).to eq [[:==,"b"],2,3]
    end

    it "should work when the code stack is populated" do
      expect(PushForthInterpreter.new([[:==,1,2],"a",3,4]).step!.stack).
        to eq [[:==,"a",1,2],3,4]
      expect(PushForthInterpreter.new([[:==,1,2],3,"a",4]).step!.stack).
        to eq [[:==,"a",1,2],3,4]
    end
  end

  describe ":≠" do
    it "should be a recognized instruction" do
      expect(PushForthInterpreter.new.instruction?(:≠)).to be true
    end

    it "should disappear if there are not two Numeric args" do
      expect(PushForthInterpreter.new([[:≠]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:≠],1]).step!.stack).to eq [[],1]
    end

    it "should return a Boolean if there are two Numerics there" do
      expect(PushForthInterpreter.new([[:≠],1,2]).step!.stack).to eq [[],true]
      expect(PushForthInterpreter.new([[:≠],1,1]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:≠],3,2]).step!.stack).to eq [[],true]
      expect(PushForthInterpreter.new([[:≠],Rational("1/4"),0.124]).step!.stack).to eq [[],true]
    end

    it "should work for Complex (unlike <=> operators)" do
      expect(PushForthInterpreter.new([[:≠],0.2r,1+1i]).step!.stack[-1]).to be true
    end

    it "should build a continuation if either of the args isn't Numeric" do
      expect(PushForthInterpreter.new([[:≠],"a",2,3]).step!.stack).to eq [[:≠,"a"],2,3]
      expect(PushForthInterpreter.new([[:≠],2,"b",3]).step!.stack).to eq [[:≠,"b"],2,3]
    end

    it "should work when the code stack is populated" do
      expect(PushForthInterpreter.new([[:≠,1,2],"a",3,4]).step!.stack).
        to eq [[:≠,"a",1,2],3,4]
      expect(PushForthInterpreter.new([[:≠,1,2],3,"a",4]).step!.stack).
        to eq [[:≠,"a",1,2],3,4]
    end
  end
end