require 'spec_helper'

describe "List instructions" do
  describe ":reverse" do
    it "should reverse a List argument" do
      expect(PushForthInterpreter.new([[:reverse],[1,2,3]]).step!.stack).
        to eq [[],[3,2,1]]
    end

    it "should fail without a List argument" do
      expect(PushForthInterpreter.new([[:reverse],77]).step!.stack).
        to eq [[],77]
    end

    it "should not reverse the guts of a List (but why would it?)" do
      expect(PushForthInterpreter.new([[:reverse],[1,[2,3]]]).step!.stack).
        to eq [[], [[2, 3], 1]]
    end
  end

  describe ":length" do
    it "should return the number of root items in a List" do
      expect(PushForthInterpreter.new([[:length],[1,2,3]]).step!.stack).
        to eq [[],3]
    end

    it "should return the number of root items in a List" do
      expect(PushForthInterpreter.new([[:length],[]]).step!.stack).
        to eq [[],0]
    end

    it "should return the number of pairs in a Dictionary" do
      d = Dictionary.new({1 => 2, 3 => 4})
      expect(PushForthInterpreter.new([[:length],d]).step!.stack).
        to eq [[],2]
    end
  end

  describe ":depth" do
    it "should return the max depth of a List" do
      expect(PushForthInterpreter.new([[:depth],[1,[[2],3]]]).step!.stack).
        to eq [[],3]
    end

    it "should work for an empty List" do
      expect(PushForthInterpreter.new([[:depth],[]]).step!.stack).
        to eq [[],1]
    end

    it "should return the number of pairs in a Dictionary" do
      d = Dictionary.new({1 => [2], 3 => 4})
      expect(PushForthInterpreter.new([[:length],d]).step!.stack).
        to eq [[],2]
    end
  end

  describe ":points" do
    it "should return total number of points in List" do
      expect(PushForthInterpreter.new([[:points],[1,[[2],3]]]).step!.stack).
        to eq [[],6]
    end

    it "should work for an empty List" do
      expect(PushForthInterpreter.new([[:points],[]]).step!.stack).
        to eq [[],1]
    end

    it "should work for a number" do
      expect(PushForthInterpreter.new([[:points],77]).step!.stack).
        to eq [[],1]
    end

    it "should return the total size of a Dictionary" do
      d = Dictionary.new({1 => [2], 3 => 4})
      expect(PushForthInterpreter.new([[:points],d]).step!.stack).
        to eq [[],6]
    end

  end

end