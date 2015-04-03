require 'spec_helper'

describe "comparison" do
  describe ">" do
    it "should disappear if there are not two arguments" do
      expect(PushForthInterpreter.new([[:>]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:>],1]).step!.stack).to eq [[],1]
    end

    it "should return a Boolean if there are two comparable items of the same type there" do
      expect(PushForthInterpreter.new([[:>],1,2]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:>],1,1]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:>],3,2]).step!.stack).to eq [[],true]
      expect(PushForthInterpreter.new([[:>],0.25r,0.22r]).step!.stack).to eq [[],true]
    end

    it "should build a continuation if arg1 isn't comparable" do
      expect(PushForthInterpreter.new([[:>],:add,2,3]).step!.stack).
        to eq [[:>,:add],2,3]
      expect(PushForthInterpreter.new([[:>],:add,:add,3]).step!.stack).to eq [[:>,:add],:add,3]
    end

    it "should build a continuation if arg2 isn't the same type as arg1" do
      expect(PushForthInterpreter.new([[:>],2,:add,3]).step!.stack).
        to eq [[:>,:add],2,3]
    end

    it "should work when the code stack is populated" do
      expect(PushForthInterpreter.new([[:>,1,2],:add,3,4]).step!.stack).
        to eq [[:>,:add,1,2],3,4]
      expect(PushForthInterpreter.new([[:>,1,2],3,:add,4]).step!.stack).
        to eq [[:>,:add,1,2],3,4]
    end

    it "should not be applied to Complex arguments" do
      expect(PushForthInterpreter.new([[:>],3+2i,3+1i]).step!.stack).to eq [[:>, (3+2i)], (3+1i)]
    end
  end

  describe "<" do
    it "should disappear if there are not two args" do
      expect(PushForthInterpreter.new([[:<]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:<],1]).step!.stack).to eq [[],1]
    end

    it "should return a Boolean if arg1 is Comparable & arg2 the same type" do
      expect(PushForthInterpreter.new([[:<],1,2]).step!.stack).to eq [[],true]
      expect(PushForthInterpreter.new([[:<],1,1]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:<],3,2]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:<],0.100,0.124]).step!.stack).to eq [[],true]
    end

    it "should build a continuation if arg1 isn't comparable" do
      expect(PushForthInterpreter.new([[:<],:add,2,3]).step!.stack).
        to eq [[:<,:add],2,3]
      expect(PushForthInterpreter.new([[:<],:add,:add,3]).step!.stack).to eq [[:<,:add],:add,3]
    end

    it "should build a continuation if arg2 isn't the same type as arg1" do
      expect(PushForthInterpreter.new([[:<],2,:add,3]).step!.stack).
        to eq [[:<,:add],2,3]
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
      expect(PushForthInterpreter.new([[:≥],0.2,0.124]).step!.stack).to eq [[],true]
    end

    it "should build a continuation if arg1 isn't comparable" do
      expect(PushForthInterpreter.new([[:≥],:add,2,3]).step!.stack).
        to eq [[:≥,:add],2,3]
      expect(PushForthInterpreter.new([[:≥],:add,:add,3]).step!.stack).to eq [[:≥,:add],:add,3]
    end

    it "should build a continuation if arg2 isn't the same type as arg1" do
      expect(PushForthInterpreter.new([[:≥],2,:add,3]).step!.stack).
        to eq [[:≥,:add],2,3]
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
      expect(PushForthInterpreter.new([[:≤],0.3,0.124]).step!.stack).to eq [[],false]
    end

    it "should build a continuation if arg1 isn't comparable" do
      expect(PushForthInterpreter.new([[:≤],:add,2,3]).step!.stack).
        to eq [[:≤,:add],2,3]
      expect(PushForthInterpreter.new([[:≤],:add,:add,3]).step!.stack).to eq [[:≤,:add],:add,3]
    end

    it "should build a continuation if arg2 isn't the same type as arg1" do
      expect(PushForthInterpreter.new([[:≤],2,:add,3]).step!.stack).
        to eq [[:≤,:add],2,3]
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
      expect(PushForthInterpreter.new([[:==],0.125,0.122]).step!.stack).to eq [[],false]
    end

    it "should work for Complexor List (unlike <=> operators)" do
      expect(PushForthInterpreter.new([[:==],3+2i,3+1i]).step!.stack).to eq [[], false]
      expect(PushForthInterpreter.new([[:==],3+1i,3+1i]).step!.stack).to eq [[], true]
      expect(PushForthInterpreter.new([[:==],[1,2],[1,2]]).step!.stack).to eq [[], true]
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
      expect(PushForthInterpreter.new([[:≠],1+1i,1+1i]).step!.stack).to eq [[], false]
    end
  end
end