require 'spec_helper'

describe "CodeGenerator" do
  describe "token_list" do
    it "should be able to produce a random token list" do
      expect( CodeGenerator.new.token_list(10).length ).to eq 10
    end

    it "should produce strings" do
      rc = CodeGenerator.new.token_list(1000)
      rc.each do |token|
        expect( token ).to be_a_kind_of(String)
      end
    end
  end

  describe "random_module" do
    it "should work for 0 tokens" do
      empty = CodeGenerator.new.random_module(0)
      expect( empty ).to eq ""
    end

    it "should produce a concatenated list of tokens" do
      expect(CodeGenerator.new.random_module(10).split(",").length).to be 10
    end
  end

  describe "random_script" do
    it "should produce a two-module PushForth script" do
      cg = CodeGenerator.new.random_script(2,2)
      expect(cg.count(",")).to eq 5
    end
  end

  describe "confirming convertibility (acceptance test)" do
    it "should interpretable scripts" do
      100.times do
        cg = CodeGenerator.new.random_script(10,10)
        expect { Script.to_code(cg) }.not_to raise_error
      end
    end
  end
end