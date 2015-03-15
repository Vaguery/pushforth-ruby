require 'rspec'
require_relative '../lib/push-forth'

describe "Boolean functions" do
  describe "and" do
    it "should be a recognized instruction" do
      expect(PushForth.new.instruction?(:and)).to be true
    end

    it "should disappear if there are not two args" do
      expect(PushForth.new([[:and]]).step!.stack).to eq [[]]
      expect(PushForth.new([[:and],true]).step!.stack).to eq [[],true]
    end

    it "should return the AND of two Booleans it finds" do
      expect(PushForth.new([[:and],false,false]).step!.stack).to eq [[],false]
      expect(PushForth.new([[:and],true,false]).step!.stack).to eq [[],false]
      expect(PushForth.new([[:and],false,true]).step!.stack).to eq [[],false]
      expect(PushForth.new([[:and],true,true]).step!.stack).to eq [[],true]
    end

    it "should build a continuation if either of the args isn't Boolean" do
      expect(PushForth.new([[:and],"a",false,true]).step!.stack).to eq [[:and,"a"],false,true]
      expect(PushForth.new([[:and],false,"b",true]).step!.stack).to eq [[:and,"b"],false,true]
    end

    it "should work when the code stack is populated" do
      expect(PushForth.new([[:and,1,2],"a",false,true]).step!.stack).
        to eq [[:and, "a", 1, 2], false, true]
      expect(PushForth.new([[:and,1,2],false,"a",true]).step!.stack).
        to eq [[:and, "a", 1, 2], false, true]
      expect(PushForth.new([[:and,1,2],false,true,"a"]).step!.stack).
        to eq [[1, 2], false, "a"]
    end
  end

  describe "or" do
    it "should be a recognized instruction" do
      expect(PushForth.new.instruction?(:or)).to be true
    end

    it "should disappear if there are not two args" do
      expect(PushForth.new([[:or]]).step!.stack).to eq [[]]
      expect(PushForth.new([[:or],true]).step!.stack).to eq [[],true]
    end

    it "should return the OR of two Booleans it finds" do
      expect(PushForth.new([[:or],false,false]).step!.stack).to eq [[],false]
      expect(PushForth.new([[:or],true,false]).step!.stack).to eq [[],true]
      expect(PushForth.new([[:or],false,true]).step!.stack).to eq [[],true]
      expect(PushForth.new([[:or],true,true]).step!.stack).to eq [[],true]
    end

    it "should build a continuation if either of the args isn't Boolean" do
      expect(PushForth.new([[:or],"a",false,true]).step!.stack).to eq [[:or,"a"],false,true]
      expect(PushForth.new([[:or],false,"b",true]).step!.stack).to eq [[:or,"b"],false,true]
    end

    it "should work when the code stack is populated" do
      expect(PushForth.new([[:or,1,2],"a",false,true]).step!.stack).
        to eq [[:or, "a", 1, 2], false, true]
      expect(PushForth.new([[:or,1,2],false,"a",true]).step!.stack).
        to eq [[:or, "a", 1, 2], false, true]
      expect(PushForth.new([[:or,1,2],false,true,"a"]).step!.stack).
        to eq [[1, 2], true, "a"]
    end
  end

  describe "not" do
    it "should be a recognized instruction" do
      expect(PushForth.new.instruction?(:not)).to be true
    end

    it "should disappear if there isn't an arg" do
      expect(PushForth.new([[:not]]).step!.stack).to eq [[]]
      expect(PushForth.new([[:not],66]).step!.stack).to eq [[],66]
    end

    it "should invert a Boolean it finds" do
      expect(PushForth.new([[:not],false]).step!.stack).to eq [[],true]
      expect(PushForth.new([[:not],true]).step!.stack).to eq [[],false]
    end

    it "should work when the code stack is populated" do
      expect(PushForth.new([[:not,1,2],false,true]).step!.stack).
        to eq [[1, 2], true, true]
    end
  end

  describe "if" do
    it "should be a recognized instruction" do
      expect(PushForth.new.instruction?(:if)).to be true
    end

    it "should disappear if it lacks two args" do
      expect(PushForth.new([[:if]]).step!.stack).to eq [[]]
      expect(PushForth.new([[:if],true]).step!.stack).to eq [[],true]
    end

    it "should dispose of arg2 if arg1 is false" do
      expect(PushForth.new([[:if],false,33]).step!.stack).to eq [[]]
      expect(PushForth.new([[:if],true,33]).step!.stack).to eq [[],33]
    end

    it "should build a continuation if arg1 isn't Boolean" do
      expect(PushForth.new([[:if],"a",false,88]).step!.stack).to eq [[:if, "a"], 88]
    end

    it "should work when the code stack is populated" do
      expect(PushForth.new([[:if,1,2],"a",false,true]).step!.stack).
        to eq [[:if, "a", 1, 2], true]
      expect(PushForth.new([[:if,1,2],false,"a",true]).step!.stack).
        to eq [[1, 2], true]
    end
  end

  describe "which" do
    it "should be a recognized instruction" do
      expect(PushForth.new.instruction?(:which)).to be true
    end

    it "should disappear if it lacks three args" do
      expect(PushForth.new([[:which]]).step!.stack).to eq [[]]
      expect(PushForth.new([[:which],true]).step!.stack).to eq [[],true]
      expect(PushForth.new([[:which],true, 6]).step!.stack).to eq [[], true, 6]
    end

    it "should dispose of arg2 if arg1 is false, or arg3 if true" do
      expect(PushForth.new([[:which],false,33,44]).step!.stack).to eq [[], 44]
      expect(PushForth.new([[:which],true,33,44]).step!.stack).to eq [[], 33]
    end

    it "should build a continuation if arg1 isn't Boolean" do
      expect(PushForth.new([[:which],33,false,44]).step!.stack).to eq [[:which, 33], false, 44]
    end

    it "should work when the code stack is populated" do
      expect(PushForth.new([[:which,1,2],"a",false,true]).step!.stack).
        to eq [[:which, "a", 1, 2], false, true]
    end
  end
end