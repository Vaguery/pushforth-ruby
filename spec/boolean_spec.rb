require 'spec_helper'

describe "Boolean functions" do
  describe "and" do
    it "should be a recognized instruction" do
      expect(PushForthInterpreter.new.instruction?(:and)).to be true
    end

    it "should disappear if there are not two args" do
      expect(PushForthInterpreter.new([[:and]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:and],true]).step!.stack).to eq [[],true]
    end

    it "should return the AND of two Booleans it finds" do
      expect(PushForthInterpreter.new([[:and],false,false]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:and],true,false]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:and],false,true]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:and],true,true]).step!.stack).to eq [[],true]
    end

    it "should build a continuation if either of the args isn't Boolean" do
      expect(PushForthInterpreter.new([[:and],"a",false,true]).step!.stack).to eq [[:and,"a"],false,true]
      expect(PushForthInterpreter.new([[:and],false,"b",true]).step!.stack).to eq [[:and,"b"],false,true]
    end

    it "should work when the code stack is populated" do
      expect(PushForthInterpreter.new([[:and,1,2],"a",false,true]).step!.stack).
        to eq [[:and, "a", 1, 2], false, true]
      expect(PushForthInterpreter.new([[:and,1,2],false,"a",true]).step!.stack).
        to eq [[:and, "a", 1, 2], false, true]
      expect(PushForthInterpreter.new([[:and,1,2],false,true,"a"]).step!.stack).
        to eq [[1, 2], false, "a"]
    end
  end

  describe "or" do
    it "should be a recognized instruction" do
      expect(PushForthInterpreter.new.instruction?(:or)).to be true
    end

    it "should disappear if there are not two args" do
      expect(PushForthInterpreter.new([[:or]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:or],true]).step!.stack).to eq [[],true]
    end

    it "should return the OR of two Booleans it finds" do
      expect(PushForthInterpreter.new([[:or],false,false]).step!.stack).to eq [[],false]
      expect(PushForthInterpreter.new([[:or],true,false]).step!.stack).to eq [[],true]
      expect(PushForthInterpreter.new([[:or],false,true]).step!.stack).to eq [[],true]
      expect(PushForthInterpreter.new([[:or],true,true]).step!.stack).to eq [[],true]
    end

    it "should build a continuation if either of the args isn't Boolean" do
      expect(PushForthInterpreter.new([[:or],"a",false,true]).step!.stack).to eq [[:or,"a"],false,true]
      expect(PushForthInterpreter.new([[:or],false,"b",true]).step!.stack).to eq [[:or,"b"],false,true]
    end

    it "should work when the code stack is populated" do
      expect(PushForthInterpreter.new([[:or,1,2],"a",false,true]).step!.stack).
        to eq [[:or, "a", 1, 2], false, true]
      expect(PushForthInterpreter.new([[:or,1,2],false,"a",true]).step!.stack).
        to eq [[:or, "a", 1, 2], false, true]
      expect(PushForthInterpreter.new([[:or,1,2],false,true,"a"]).step!.stack).
        to eq [[1, 2], true, "a"]
    end
  end

  describe "not" do
    it "should be a recognized instruction" do
      expect(PushForthInterpreter.new.instruction?(:not)).to be true
    end

    it "should disappear if there isn't an arg" do
      expect(PushForthInterpreter.new([[:not]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:not],66]).step!.stack).to eq [[],66]
    end

    it "should invert a Boolean it finds" do
      expect(PushForthInterpreter.new([[:not],false]).step!.stack).to eq [[],true]
      expect(PushForthInterpreter.new([[:not],true]).step!.stack).to eq [[],false]
    end

    it "should work when the code stack is populated" do
      expect(PushForthInterpreter.new([[:not,1,2],false,true]).step!.stack).
        to eq [[1, 2], true, true]
    end
  end

  describe "if" do
    it "should be a recognized instruction" do
      expect(PushForthInterpreter.new.instruction?(:if)).to be true
    end

    it "should disappear if it lacks two args" do
      expect(PushForthInterpreter.new([[:if]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:if],true]).step!.stack).to eq [[],true]
    end

    it "should dispose of arg2 if arg1 is false" do
      expect(PushForthInterpreter.new([[:if],false,33]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:if],true,33]).step!.stack).to eq [[],33]
    end

    it "should build a continuation if arg1 isn't Boolean" do
      expect(PushForthInterpreter.new([[:if],"a",false,88]).step!.stack).to eq [[:if, "a"], 88]
    end

    it "should work when the code stack is populated" do
      expect(PushForthInterpreter.new([[:if,1,2],"a",false,true]).step!.stack).
        to eq [[:if, "a", 1, 2], true]
      expect(PushForthInterpreter.new([[:if,1,2],false,"a",true]).step!.stack).
        to eq [[1, 2], true]
    end
  end

  describe "which" do
    it "should be a recognized instruction" do
      expect(PushForthInterpreter.new.instruction?(:which)).to be true
    end

    it "should disappear if it lacks three args" do
      expect(PushForthInterpreter.new([[:which]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:which],true]).step!.stack).to eq [[],true]
      expect(PushForthInterpreter.new([[:which],true, 6]).step!.stack).to eq [[], true, 6]
    end

    it "should dispose of arg2 if arg1 is false, or arg3 if true" do
      expect(PushForthInterpreter.new([[:which],false,33,44]).step!.stack).to eq [[], 44]
      expect(PushForthInterpreter.new([[:which],true,33,44]).step!.stack).to eq [[], 33]
    end

    it "should build a continuation if arg1 isn't Boolean" do
      expect(PushForthInterpreter.new([[:which],33,false,44]).step!.stack).to eq [[:which, 33], false, 44]
    end

    it "should work when the code stack is populated" do
      expect(PushForthInterpreter.new([[:which,1,2],"a",false,true]).step!.stack).
        to eq [[:which, "a", 1, 2], false, true]
    end
  end
end