require 'rspec'
require_relative '../lib/push-forth'
include PushForth

describe "the :while instruction" do

  it "should be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:while)).to be true
  end

  # this might become a continuation form later
  it "should do nothing unless there are three list args available" do
    expect(PushForthInterpreter.new([[:while]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:while],1]).step!.stack).to eq [[],1]
    expect(PushForthInterpreter.new([[:while],[1],2]).step!.stack).to eq [[],[1],2]
    expect(PushForthInterpreter.new([[:while],[1],[2]]).step!.stack).to eq [[],[1],[2]]
    expect(PushForthInterpreter.new([[:while],[1],[2],3]).step!.stack).to eq [[],[1],[2],3]
    expect(PushForthInterpreter.new([[:while],1,[2],[3]]).step!.stack).to eq [[],1,[2],[3]]
    expect(PushForthInterpreter.new([[:while],[1],2,[3]]).step!.stack).to eq [[],[1],2,[3]]
  end

  it "should halt if the second arg is an empty list" do
    expect(PushForthInterpreter.new([[:while],[1],[],[3]]).step!.stack).
      to eq [[],[],[3]]
    expect(PushForthInterpreter.new([[:while,"a"],[1],[],[3]]).step!.stack).
      to eq [["a"],[],[3]]
  end

  it "should build The Thing otherwise" do
    # while([ X Z Y ]) = [ [ X [ X while ] i ] Y ]
    d = PushForthInterpreter.new([[:while],[1],[2],[3]])
    d.step!
    expect(d.stack).to eq [[1, [[1], :while], :enlist], [3]]
  end

  it "should work the way Maarten's paper describes" do
    # I have no idea how long it will take, but I know the eventual answer
    runner = PushForthInterpreter.new([[[[]],[:eval,:dup,:car],:while],[[1,1,:add]]])
    trace = 100.times.collect {runner.step!.stack}
    expect(trace[-1]).to eq [[], [], [[], 2]]

    # Why not? A program's a program, no matter how nested
    runner = PushForthInterpreter.new([[[[]],[:eval,:dup,:car],:while],[[[[]],[:eval,:dup,:car],:while],[[1,1,:add]]]])
    trace = 1000.times.collect {runner.step!.stack}
    expect(trace[-1]).to eq [[], [], [[], [], [[], 2]]]
  end
end