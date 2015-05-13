require 'spec_helper'

describe "Script.to_code" do
  it "should produce an empty program for an empty string" do
    expect(Script.to_code("")).to eq []
  end

  it "should put anything it contains into an array" do
    expect(Script.to_code("3")).to eq [3]
  end

  it "should put anything it contains into an array" do
    expect(Script.to_code("3,9")).to eq [3,9]
  end

  it "should work for PushForth scripts with basic types in them" do
    expect(Script.to_code("[, :foo, 3, ], [, ], -4.125, [, 8, :bar, ]")).
      to eq [[:foo, 3], [], -4.125, [8, :bar]]
  end

  it "should recognize integers" do
    expect(Script.to_code("-9912")).to eq [-9912]
  end

  it "should recognize ranges" do
    expect(Script.to_code("91..111")).to eq [91..111]
    expect(Script.to_code("-9.1..11.1")).to eq [-9.1..11.1]
  end

  it "should recognize arrays" do
    expect(Script.to_code("[,],[,[,],[,[,],[,],],]")).to eq [[], [[], [[], []]]]
  end

  it "should recognize symbols" do
    expect(Script.to_code(":foo, :bar, :baz")).to eq [:foo, :bar, :baz]
  end

  it "should recognize rationals" do
    expect(Script.to_code("(95/88),(1/4)")).to eq [(95/88),(1/4)]
  end

  it "should throw away unused close brackets" do
    expect(Script.to_code("]")).to eq []
  end

  it "should throw away unused close brackets" do
    expect(Script.to_code("],[,],[")).to eq [[],[]]
  end


  it "should close unmatched open brackets" do
    expect(Script.to_code("[")).to eq [[]]
    expect(Script.to_code("[,[,[")).to eq [[[[]]]]
  end

  it "should work with extra commas" do
    expect(Script.to_code("[,,[,,],[],]")).to eq [[[], []]]
  end
end

describe "freaky crossover stuff" do
  it "should act as I wish not as I said" do
    a = "[,[,1,2,],3,[,4,[,5,],],]"
    b = "1,2,3,[,[,[,[,4,],],],]"
    expect(Script.to_code(a)).to eq [[[1, 2], 3, [4, [5]]]]
    expect(Script.to_code(b)).to eq [1, 2, 3, [[[[4]]]]]
    cx = (a.split(",")[0..6] + b.split(",")[-6..-1]).join(",")
    expect(Script.to_code(cx)).to eq [[[1, 2], 3, [[4]]]]
  end

  it "should act as I wish not as I said" do
    a = "[,[,[,[,[,[,[,[,[,[,[,[,["
    b = "1,2,3,4,5,6,7,8,9,0"
    cx = (a.split(",")[0..6] + b.split(",")[-6..-1]).join(",")
    expect(Script.to_code(cx)).to eq [[[[[[[[5, 6, 7, 8, 9, 0]]]]]]]]
  end

end