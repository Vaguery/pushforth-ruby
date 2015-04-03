require 'spec_helper'


describe ":map" do
  it "shouldn't work unless there are at least two arguments" do
    expect(PushForthInterpreter.new([[:map]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:map],1]).step!.stack).to eq [[],1]
  end

  it "should build a 'mapping' on the CODE stack if they're both lists" do
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
    expect(PushForthInterpreter.new([[:map],1, 2,3,4]).step!.stack).
      to eq [[1, 2], 3, 4]
  end

  it "clones any argument that is a list" do
    pf = PushForthInterpreter.new([[:map],[[1,[2]]],[[:dup,[:add,8]]]])
    oldID_1 = pf.stack[1].object_id
    oldID_2 = pf.stack[2].object_id
    pf.step!
    expect(pf.stack).to eq [[[1, [2]], [:dup, [:add, 8]]]]
    expect(pf.stack[0].object_id).not_to eq oldID_1
    expect(pf.stack[0][1].object_id).not_to eq oldID_2
  end
end





describe "append_to_leaves helper" do
  it "should insert items between the things if it's a flat array" do
    pf = PushForthInterpreter.new
    expect(pf.append_to_leaves([1,2,3],[4])).
      to eq [1, 4, 2, 4, 3, 4]
    expect(pf.append_to_leaves([1,2,3],[4,5])).
      to eq [1, 4, 5, 2, 4, 5, 3, 4, 5]
    expect(pf.append_to_leaves([],[4])).
      to eq []
  end

  it "insert should items after all leaves if it's a tree array" do
    pf = PushForthInterpreter.new
    expect(pf.append_to_leaves([1,[2],3],[4])).
      to eq [1, 4, [2, 4], 3, 4]
    expect(pf.append_to_leaves([1,[2,[3]]],[[4],5])).
      to eq [1, [4], 5, [2, [4], 5, [3, [4], 5]]]
    expect(pf.append_to_leaves([[[1],[],[[]]]],[4])).
      to eq [[[1, 4], [], [[]]]]
  end
end


describe ":leafmap" do
  it "be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:leafmap)).to be true
  end

  it "shouldn't work unless there are at least two arguments" do
    expect(PushForthInterpreter.new([[:leafmap]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:leafmap],1]).step!.stack).to eq [[],1]
  end

  it "should insert arg2 with every leaf of arg1, if they're both lists, on the CODE stack" do
    expect(PushForthInterpreter.new([[:leafmap],[1,2],[:dup]]).step!.stack).
      to eq [[1, :dup, 2, :dup]] # works like :map
    expect(PushForthInterpreter.new([[:leafmap],[1,[2]],[:dup,:cons]]).step!.stack).
      to eq [[1, :dup, :cons, [2, :dup, :cons]]]
  end

  it "should not over-flatten the mapped item(s)" do
    expect(PushForthInterpreter.new([[:leafmap],[1,[2]],[:dup,[:add,8],:map]]).step!.stack).
    to eq [[1,:dup,[:add,8], :map, [2, :dup, [:add, 8], :map]]]
  end

  it "should work fine when arg2 isn't a list" do
    expect(PushForthInterpreter.new([[:leafmap],[1,[2]],:dup]).step!.stack).
    to eq [[[1, :dup, [2, :dup]]]]
  end

  it "should build a 'mapping' on the code stack if arg1 isn't a list" do
    expect(PushForthInterpreter.new([[:leafmap],1,[:dup,[:cons]],2,3]).step!.stack).
      to eq [[1, :dup, [:cons]], 2, 3]
    expect(PushForthInterpreter.new([[:leafmap],1,[[],[]]]).step!.stack).
      to eq [[1, [], []]]
  end

  it "should build a 'mapping' on the code stack when neither is a list" do
    expect(PushForthInterpreter.new([[:leafmap],1, 2]).step!.stack).
      to eq [[1, 2]]
  end
end
