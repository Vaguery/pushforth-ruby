require 'rspec'
require_relative '../lib/push-forth'
include PushForth

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
  end

  describe "getting" do
    it "should retrieve values" do
      d = Dictionary.new
      d.set(3,Dictionary.new)
      expect(d.get(3)).to be_a_kind_of PushForth::Dictionary
    end

    it "should return an Error if the key's unknown" do
      d = Dictionary.new
      expect(d.get(3)).to be_a_kind_of PushForth::Error
      expect(d.get(3).string).to eq "key not found"
    end
  end


  describe ":dict" do
    it "should be a recognized instruction" do
      expect(PushForthInterpreter.new.instruction?(:dict)).to be true
    end

    it "should create a new Dictionary (empty)" do
      expect(PushForthInterpreter.new([[:dict],3]).step!.stack[1]).to be_a_kind_of Dictionary
    end
  end


  describe ":set" do
    it "should be a recognized instruction" do
      expect(PushForthInterpreter.new.instruction?(:set)).to be true
    end

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
    it "should be a recognized instruction" do
      expect(PushForthInterpreter.new.instruction?(:get)).to be true
    end

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

    it "should return an Error object if the key's not found" do
      d = Dictionary.new
      expected_error = PushForthInterpreter.new([[:get],d,2]).step!.stack[1]
      expect(expected_error).to be_a_kind_of(PushForth::Error)
      expect(expected_error.string).to eq "key not found"
    end
  end
end