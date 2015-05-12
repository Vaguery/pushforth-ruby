require 'spec_helper'

describe "Script.to_program" do
  it "should produce an empty program for an empty string" do
    expect(Script.to_program("")).to eq []
  end

  it "should put anything it contains into an array" do
    expect(Script.to_program("3")).to eq [3]
  end

  it "should work for PushForth scripts with basic types in them" do
    expect(Script.to_program("[[:foo, 3], [], -4.125,[8,:bar]]")).
      to eq [[:foo, 3], [], -4.125, [8, :bar]]
  end

  it "should recognize integers" do
    expect(Script.to_program("-9912")).to eq [-9912]
  end

  it "should recognize ranges" do
    expect(Script.to_program("91..111")).to eq [91..111]
    expect(Script.to_program("-9.1..11.1")).to eq [-9.1..11.1]
  end

  it "should recognize arrays" do
    expect(Script.to_program("[[],[[],[[],[]]]]")).to eq [[], [[], [[], []]]]
  end

  it "should recognize symbols" do
    expect(Script.to_program("[:foo, :bar, :baz]")).to eq [:foo, :bar, :baz]
  end

  it "should recognize rationals" do
    expect(Script.to_program("[(95/88),(1/4)]")).to eq [(95/88),(1/4)]

  it
end