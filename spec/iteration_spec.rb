require 'spec_helper'

describe ":until0" do
  it "shouldn't work unless there are at least three arguments" do
    expect(PushForthInterpreter.new([[:until0]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:until0],1]).step!.stack).to eq [[],1]
    expect(PushForthInterpreter.new([[:until0],1,2]).step!.stack).to eq [[],1,2]
  end

  it "should build a continuation if arg1 isn't a positive Integer" do
    expect(PushForthInterpreter.new([[:until0],-1,1,2]).step!.stack).
      to eq [[:until0,-1],1,2]
    expect(PushForthInterpreter.new([[:until0],[0],1,2]).step!.stack).
      to eq [[:until0,[0]],1,2]
    expect(PushForthInterpreter.new([[:until0],:add,1,:add]).step!.stack).
      to eq [[:until0,:add], 1, :add]
  end

  it "should build a continuation if arg2 isn't a List" do
    expect(PushForthInterpreter.new([[:until0],1,2,[3]]).step!.stack).
      to eq [[:until0,2],1,[3]]
    expect(PushForthInterpreter.new([[:until0],1,:foo,[2]]).step!.stack).
      to eq [[:until0,:foo],1,[2]]
  end

  it "should build a continuation if arg3 isn't a List" do
    expect(PushForthInterpreter.new([[:until0],1,[2],3]).step!.stack).
      to eq [[:until0,3],1,[2]]
    expect(PushForthInterpreter.new([[:until0],1,[:foo],3]).step!.stack).
      to eq [[:until0,3],1,[:foo]]
  end

  it "should decrement the integer if positive and build a continuation" do
    expect(PushForthInterpreter.new([[:until0],1,[1],[:add]]).step!.stack).
      to eq [[:add, [:add], [1], 0, :until0]]
    expect(PushForthInterpreter.new([[:until0],13,[1],[:add]]).step!.stack).
      to eq [[:add, [:add], [1], 12, :until0]]
  end

  it "should return the second argument when it reaches a 0 counter" do
    expect(PushForthInterpreter.new([[:until0],0,[33],[:add]]).step!.stack).
      to eq [[33]]
  end

  it "should actually recurse" do
    pf = PushForthInterpreter.new([[:until0],7,[1],[:dup,:add],99]).step!
    expect(pf.stack).to eq [[:dup, :add, [:dup, :add], [1], 6, :until0], 99]
    pf.step!
    expect(pf.stack).to eq [[:add, [:dup, :add], [1], 6, :until0], 99, 99]
    pf.step!
    expect(pf.stack).to eq [[[:dup, :add], [1], 6, :until0], 198]
    pf.step!
    expect(pf.stack).to eq [[[1], 6, :until0], [:dup, :add], 198]
    pf.step!
    expect(pf.stack).to eq [[6, :until0], [1], [:dup, :add], 198]
    pf.step!
    expect(pf.stack).to eq [[:until0], 6, [1], [:dup, :add], 198]
    pf.step!
    expect(pf.stack).to eq [[:dup, :add, [:dup, :add], [1], 5, :until0], 198]
    pf.step!
    expect(pf.stack).to eq [[:add, [:dup, :add], [1], 5, :until0], 198, 198]
    pf.step!
    expect(pf.stack).to eq [[[:dup, :add], [1], 5, :until0], 396]
    pf.step!
    expect(pf.stack).to eq [[[1], 5, :until0], [:dup, :add], 396]
    # ...
    pf.run
    expect(pf.stack).to eq [[], 1, 12672]
  end
end

describe "do_times" do
  it "should disappear if there aren't 2 arguments" do
    expect(PushForthInterpreter.new([[:do_times],1]).step!.stack).
      to eq [[], 1]
    expect(PushForthInterpreter.new([[:do_times]]).step!.stack).
      to eq [[]]
  end

  it "should do nothing if arg1 is an Integer 0 or less" do
    expect(PushForthInterpreter.new([[:do_times],0,[4,4]]).step!.stack).
      to eq [[], [4,4]]
    expect(PushForthInterpreter.new([[:do_times],-10,[4,4]]).step!.stack).
      to eq [[], [4,4]]
  end

  it "should run the top List code if arg1 is an Integer 1 or more, and count down" do
    expect(PushForthInterpreter.new([[:do_times],1,[4,4]]).step!.stack).
      to eq [[4, 4, [4, 4], 0, :do_times]]
    expect(PushForthInterpreter.new([[:do_times],123,[4,4]]).step!.stack).
      to eq [[4, 4, [4, 4], 122, :do_times]]
  end

  it "should set aside the integer if arg2 is not a List" do
    expect(PushForthInterpreter.new([[:do_times],1,4]).step!.stack).
      to eq [[:do_times, 4], 1]
  end

  it "should set aside the List if arg1 is not an Integer" do
    expect(PushForthInterpreter.new([[:do_times],:add,[8],11]).step!.stack).
      to eq [[:swap, :do_times, :add], [8], 11]
  end
end


describe "the :while instruction" do
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