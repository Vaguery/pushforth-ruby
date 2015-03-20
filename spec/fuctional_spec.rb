require 'rspec'
require_relative '../lib/push-forth'
include PushForth


describe ":map" do
  it "be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:map)).to be true
  end

  it "shouldn't work unless there are at least two arguments" do
    expect(PushForthInterpreter.new([[:map]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:map],1]).step!.stack).to eq [[],1]
  end

  it "should build a 'mapping' on the code stack if they're both lists" do
    expect(PushForthInterpreter.new([[:map],[1,2],[:dup]]).step!.stack).
      to eq [[1, :dup, 2, :dup]]
    expect(PushForthInterpreter.new([[:map],[1,2],[:dup,:cons]]).step!.stack).
      to eq [[1, :dup, :cons, 2, :dup, :cons]]
  end

  it "should not over-flatten the mapped item(s)" do
    expect(PushForthInterpreter.new([[:map],[1,[2]],[:dup,[:add,8],:map]]).step!.stack).
    to eq [[1,:dup,[:add,8], :map, [2], :dup, [:add, 8], :map]]
  end

  it "should build a 'mapping' on the code stack if arg1 isn't a list" do
    expect(PushForthInterpreter.new([[:map],1,[:dup]]).step!.stack).
      to eq [[1, :dup]]
  end

  it "should build a 'mapping' on the code stack when neither is a list" do
    expect(PushForthInterpreter.new([[:map],1, 2]).step!.stack).
      to eq [[1, 2]]
  end
end
