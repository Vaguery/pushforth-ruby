require 'spec_helper'

describe "Dictionary" do
  describe "setting" do
    it "should store values" do
      d = Dictionary.new
      d.set(3,Dictionary.new)
      expect(d.contents[3]).to be_a_kind_of PushForth::Dictionary
      fancy_key = Dictionary.new
      d.set(fancy_key,3)
      expect(d.contents.keys).to include fancy_key
    end

    it "should use deep_copy to copy stored values if possible" do
      d = Dictionary.new
      did = d.object_id
      d.set(3,d) # would form a loop!
      expect(d.contents[3].object_id).not_to eq did
    end

    it "should clone keys" do
      d = Dictionary.new
      d.set([3],88) 
      did = d.keys[0].object_id
      expect(d.clone.keys[0].object_id).not_to eq did
    end
  end

  describe "getting" do
    it "should retrieve values" do
      d = Dictionary.new
      d.set(3,Dictionary.new)
      expect(d.get(3)).to be_a_kind_of PushForth::Dictionary
    end

    it "should have no return value if the key's unknown" do
      d = Dictionary.new
      expect(d.get(3)).to be nil
    end
  end

  describe ":dict" do
    it "should create a new Dictionary (empty)" do
      expect(PushForthInterpreter.new([[:dict],3]).step!.stack[1]).to be_a_kind_of Dictionary
    end
  end


  describe ":set" do
    it "should disappear if there are not three args" do
      expect(PushForthInterpreter.new([[:set]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:set],1]).step!.stack).to eq [[],1]
      expect(PushForthInterpreter.new([[:set],1,1]).step!.stack).to eq [[],1,1]
    end

    it "should set the key:value pair in the Dictionary if the args match" do
      d = Dictionary.new
      d.set(3,4)
      pf = PushForthInterpreter.new( [[:set],d,11,99])
      expect(pf.step!.stack[1].contents[11]).to eq 99
    end

    it "should build a continuation if the first arg is not a Dictionary" do
      expect(PushForthInterpreter.new([[:set],"a",2,3]).step!.stack).to eq [[:set, "a"], 2, 3]
    end
  end

  describe ":get" do

    it "should disappear if there are not two args" do
      expect(PushForthInterpreter.new([[:get]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:get],1]).step!.stack).to eq [[],1]
    end

    it "should get the value for a given key, keeping the Dictionary" do
      d = Dictionary.new
      d.set(3,4)
      pf = PushForthInterpreter.new( [[:get],d,3])
      expect(pf.step!.stack).to eq [[], 4, d]
    end

    it "should build a continuation if the first arg is not a Dictionary" do
      expect(PushForthInterpreter.new([[:get],"a",2,3]).step!.stack).to eq [[:get, "a"], 2, 3]
    end

    it "should not return any value if the key's not found, but keep the Dictionary" do
      d = Dictionary.new
      expect(PushForthInterpreter.new([[:get],d,2]).step!.stack).
        to eq [[],d]
    end
  end

  describe "merge" do
    it "should disappear if there are not two args" do
      expect(PushForthInterpreter.new([[:merge]]).step!.stack).to eq [[]]
      expect(PushForthInterpreter.new([[:merge],1]).step!.stack).to eq [[],1]
    end

    it "should merge the hash of arg2 into arg1" do
      d1 = Dictionary.new({1 => 2})
      d2 = Dictionary.new({3 => 4})
      expect(PushForthInterpreter.new([[:merge],d1,d2]).step!.stack[1].contents).
        to eq({1=>2, 3=>4})
    end

    it "should overwrite arg1 with arg2 as necessary" do
      d1 = Dictionary.new({1 => 2})
      d2 = Dictionary.new({1 => 4,2=>3})
      expect(PushForthInterpreter.new([[:merge],d1,d2]).step!.stack[1].contents).
        to eq({1=>4, 2=>3})
    end

    it "should work as expcted if arg2 is empty" do
      d1 = Dictionary.new({1 => 2})
      d2 = Dictionary.new
      expect(PushForthInterpreter.new([[:merge],d1,d2]).step!.stack[1].contents).
        to eq({1=>2})
    end
  end
end