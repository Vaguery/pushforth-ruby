require 'spec_helper'


describe "Range instructions" do
  describe ":cover?" do
    it "should return a Boolean indicating whether the Range covers a Number" do
      expect(PushForthInterpreter.new([[:cover?],(3..11),4]).step!.stack).to eq [[], true]
      expect(PushForthInterpreter.new([[:cover?],(3..11),112]).step!.stack).to eq [[], false]

      expect(PushForthInterpreter.new([[:cover?],(3..11),6.21]).step!.stack).to eq [[], true]
      expect(PushForthInterpreter.new([[:cover?],(3..11),Rational("42/8")]).
        step!.stack).to eq [[], true]
    end

    it "should build a continuation if arg1 is a Range but arg2 isn't a match" do
      expect(PushForthInterpreter.new([[:cover?],(3..11),:add]).step!.stack).
        to eq [[:cover?, :add], 3..11]
    end

    it "should build a continuation if arg1 isn't a Range but arg2 is a match" do
      expect(PushForthInterpreter.new([[:cover?],:add,8]).step!.stack).
        to eq [[:swap, :cover?, :add], 8]
    end

    it "should die if neither arg matches" do
      expect(PushForthInterpreter.new([[:cover?],:add,:add]).step!.stack).
        to eq [[], :add, :add]
    end

  end
end