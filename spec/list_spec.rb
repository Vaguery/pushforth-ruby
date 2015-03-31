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
end