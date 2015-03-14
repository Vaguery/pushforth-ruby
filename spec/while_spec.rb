require 'rspec'
require_relative '../lib/push-forth'

describe "the :while instruction" do

  it "should be a recognized instruction" do
    expect(PushForth.new.instruction?(:while)).to be true
  end

  # this might become a continuation form later
  it "should do nothing unless there are three list args available" do
    expect(PushForth.new([[:while]]).step!.stack).to eq [[]]
    expect(PushForth.new([[:while],1]).step!.stack).to eq [[],1]
    expect(PushForth.new([[:while],[1],2]).step!.stack).to eq [[],[1],2]
    expect(PushForth.new([[:while],[1],[2]]).step!.stack).to eq [[],[1],[2]]
    expect(PushForth.new([[:while],[1],[2],3]).step!.stack).to eq [[],[1],[2],3]
    expect(PushForth.new([[:while],1,[2],[3]]).step!.stack).to eq [[],1,[2],[3]]
    expect(PushForth.new([[:while],[1],2,[3]]).step!.stack).to eq [[],[1],2,[3]]
  end

  it "should halt if the second arg is an empty list" do
    expect(PushForth.new([[:while],[1],[],[3]]).step!.stack).
      to eq [[],[],[3]]
    expect(PushForth.new([[:while,"a"],[1],[],[3]]).step!.stack).
      to eq [["a"],[],[3]]
  end

  it "should build The Thing otherwise" do
    # while([ X Z Y ]) = [ [ X [ Z while ] i ] Y ]
    d = PushForth.new([[:while],[1],[2],[3]])
    d.step!
    expect(d.stack).to eq [[1, [[1], :while], :enlist], [3]]
  end

  it "should work the way Maarten's paper describes" do
    runner = PushForth.new([[[[]],[:eval,:dup,:car],:while],[[1,1,:add]]])
    runner.step!
    expect(runner.stack).
      to eq [[[:eval, :dup, :car], :while], [[]], [[1, 1, :add]]]
    runner.step!
    expect(runner.stack).
      to eq [[:while], [:eval, :dup, :car], [[]], [[1, 1, :add]]]
    runner.step!
    expect(runner.stack).
      to eq [[:eval, :dup, :car, [[:eval, :dup, :car], :while], :enlist], 
              [[1, 1, :add]]]
    runner.step!
    expect(runner.stack).
      to eq [[:dup, :car, [[:eval, :dup, :car], :while], :enlist], [], [1, 1,
              :add]]  #### WRONG  :eval                            ^^
                #                                                  [[1,:add],1]     
    runner.step!
    expect(runner.stack).
      to eq [[:car, [[:eval, :dup, :car], :while], :enlist], [], [], [1, 1, :add]]
    runner.step!
    expect(runner.stack).
      to eq [[[[:eval, :dup, :car], :while], :enlist], [], [1, 1, :add]]
    runner.step!
    expect(runner.stack).
      to eq [[:enlist], [[:eval, :dup, :car], :while], [], [1, 1, :add]]
    runner.step!
    expect(runner.stack).
      to eq [[[:eval, :dup, :car], :while], [], [1, 1, :add]]
    runner.step!
    expect(runner.stack).
      to eq [[:while], [:eval, :dup, :car], [], [1, 1, :add]]
    runner.step!
    expect(runner.stack).
      to eq [[], [], [1, 1, :add]]
  end
end