require 'spec_helper'

describe ":dup" do

  it "should actually duplicate the top remaining item" do
    d = PushForthInterpreter.new([[1,:dup]])
    expect(d.step!.stack).to eq [[:dup],1]
    expect(d.step!.stack).to eq [[],1,1]
  end

  it "should disappear if there's nothing on the stack" do
    d = PushForthInterpreter.new([[:dup]])
    expect(d.step!.stack).to eq [[]]
  end

  it "should work for fancy arguments" do
    d = PushForthInterpreter.new([[:dup],[[[[[[1],2],3],4],5],6],7])
    expect(d.step!.stack).to eq(
      [[], [[[[[[1], 2], 3], 4], 5], 6], [[[[[[1], 2], 3], 4], 5], 6], 7])
  end

  it "should work when the :code stack is populated" do
    d = PushForthInterpreter.new([[:dup,1,2],3,4])
    expect(d.step!.stack).to eq [[1,2],3,3,4]
  end
end


describe "swap" do
  it "should disappear unless there are two args" do
    expect(PushForthInterpreter.new([[:swap]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:swap],1]).step!.stack).to eq [[],1]
  end

  it "should swap things if there are at least two" do
    expect(PushForthInterpreter.new([[:swap],1,2]).step!.stack).to eq [[],2,1]
    expect(PushForthInterpreter.new([[:swap],1,2,3,4]).step!.stack).to eq [[],2,1,3,4]
  end

  it "should work for fancy items" do
    d = PushForthInterpreter.new([[:swap],[[[[[[1],2],3],4],5],6],7])
    expect(d.step!.stack).to eq [[], 7, [[[[[[1], 2], 3], 4], 5], 6]]
  end

  it "should work when the :code stack is populated" do
    d = PushForthInterpreter.new([[:swap,1,2],3,4])
    expect(d.step!.stack).to eq [[1,2],4,3]
  end
end


describe "rotate" do

  it "should disappear unless there are three args" do
    expect(PushForthInterpreter.new([[:rotate]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:rotate],1]).step!.stack).to eq [[],1]
    expect(PushForthInterpreter.new([[:rotate],1,2]).step!.stack).to eq [[],1,2]
  end

  it "should rotate things if there are at least three" do
    expect(PushForthInterpreter.new([[:rotate],1,2,3]).step!.stack).to eq [[],2,3,1]
    expect(PushForthInterpreter.new([[:rotate],1,2,3,4]).step!.stack).to eq [[],2,3,1,4]
  end

  it "should work for fancy items" do
    d = PushForthInterpreter.new([[:rotate],[[[[[[1],2],3],4],5],6],7,8,9])
    expect(d.step!.stack).to eq [[], 7, 8, [[[[[[1], 2], 3], 4], 5], 6], 9]
  end

  it "should work when the :code stack is populated" do
    d = PushForthInterpreter.new([[:rotate,1,2],3,4,5,6])
    expect(d.step!.stack).to eq [[1,2],4,5,3,6]
  end
end


describe ":enlist (i combinator)" do
  it "should disappear unless there is an argument" do
    expect(PushForthInterpreter.new([[:enlist]]).step!.stack).to eq [[]]
  end

  it "should form a continuation if arg1 isn't a list" do
    expect(PushForthInterpreter.new([[:enlist],1,2]).step!.stack).to eq [[:enlist, 1], 2]
  end

  it "should queue a list from the data stack for execution" do
    expect(PushForthInterpreter.new([[:enlist],[1,2],3]).step!.stack).to eq(
      [[1,2],3])
    expect(PushForthInterpreter.new([[:enlist],[1,[2]],3,4]).step!.stack).to eq(
      [[1,[2]],3,4])
  end

  it "should append the new code to the _tail_ of the CODE stack" do
    d = PushForthInterpreter.new([[:enlist,1,2],[3],4])
    expect(d.step!.stack).to eq [[1,2,3],4]
  end

  it "should ignore a non-list item" do
    expect(PushForthInterpreter.new([[:enlist,88],1,2,3]).step!.stack).to eq(
      [[:enlist,1,88],2,3])
  end
end


describe ":cons" do
  it "should won't work unless there are two args" do
    expect(PushForthInterpreter.new([[:cons]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:cons],7]).step!.stack).to eq [[],7]
  end

  it "uses a continuation form if the second arg isn't a list" do
    expect(PushForthInterpreter.new([[:cons],1,2,3]).step!.stack).to eq [[:cons, 2], 1, 3]
    expect(PushForthInterpreter.new([[:cons, 2], 1, 3]).step!.stack).to eq(
      [[:cons, 3, 2], 1])
  end

  it "prepends the first arg onto the second (a list)" do
    expect(PushForthInterpreter.new([[:cons],1,[2]]).step!.stack).to eq [[],[1,2]]
    expect(PushForthInterpreter.new([[:cons],[1],[2]]).step!.stack).to eq [[],[[1],2]]
  end

  it "should work when the :code stack is populated" do
    expect(PushForthInterpreter.new([[:cons,1,2,3],4,[5]]).step!.stack).to eq(
      [[1, 2, 3], [4, 5]])
  end
end


describe ":pop!" do
  it "should disappear if the data stack is empty" do
    expect(PushForthInterpreter.new([[:pop!]]).step!.stack).to eq [[]]
  end

  it "should delete the top item on the data stack" do
    expect(PushForthInterpreter.new([[:pop!],1,2,3]).step!.stack).to eq [[], 2, 3]
    expect(PushForthInterpreter.new([[:pop!],[1, 2],3]).step!.stack).to eq [[],3]
  end

  it "should work when the :code stack is populated" do
    expect(PushForthInterpreter.new([[:pop!,1,2,3],4,[5]]).step!.stack).to eq(
      [[1, 2, 3], [5]])
  end
end


describe ":pop" do
  it "should disappear if there is no arg" do
    expect(PushForthInterpreter.new([[:pop]]).step!.stack).to eq [[]]
  end

  it "should have a continuation form when the arg isn't a nonempty List" do
    expect(PushForthInterpreter.new([[:pop],1,[2]]).step!.stack).
      to eq [[:pop,1], [2]]
  end

  it "should pop (and store) the top item of the arg" do
    expect(PushForthInterpreter.new([[:pop],[1,2]]).step!.stack).to eq [[], 1, [2]]
    expect(PushForthInterpreter.new([[:pop],[[1,2],3],4]).step!.stack).to eq(
      [[], [1, 2], [3], 4])
  end

  it "should work when the :code stack is populated" do
    expect(PushForthInterpreter.new([[:pop,1,2],[3,4]]).step!.stack).to eq [[1,2],3,[4]]
  end

  it "should have no (net) effect when the list is empty" do
    expect(PushForthInterpreter.new([[:pop],[]]).step!.stack).to eq [[], []]
  end
end


describe ":car" do
  it "should disappear without any argument" do
    expect(PushForthInterpreter.new([[:car]]).step!.stack).to eq [[]]
  end

  it "should have a continuation if the arg isn't a list" do
    expect(PushForthInterpreter.new([[:car],1]).step!.stack).to eq [[:car,1]]
  end

  it "should shift off the top item of the top item on the data stack" do
    expect(PushForthInterpreter.new([[:car],[1,2]]).step!.stack).to eq [[], 1]
    expect(PushForthInterpreter.new([[:car],[[1,2],3],4]).step!.stack).to eq [[],[1,2],4]
  end

  it "should work when the :code stack is populated" do
    expect(PushForthInterpreter.new([[:car,1,2],[3,4]]).step!.stack).to eq [[1,2],3]
  end

  it "should delete an empty list argument" do
    expect(PushForthInterpreter.new([[:car],[]]).step!.stack).to eq [[]]
  end
end


describe ":cdr" do
  it "should disappear if the top item isn't a list" do
    expect(PushForthInterpreter.new([[:cdr]]).step!.stack).to eq [[]]
  end

  it "should have a continuation form if the arg isn't a List" do
    expect(PushForthInterpreter.new([[:cdr],1]).step!.stack).to eq [[:cdr,1]]
  end

  it "should delete the top item of the top item on the data stack" do
    expect(PushForthInterpreter.new([[:cdr],[1,2]]).step!.stack).to eq [[], [2]]
    expect(PushForthInterpreter.new([[:cdr],[[1,2],3],4]).step!.stack).to eq [[],[3],4]
  end

  it "should work when the :code stack is populated" do
    expect(PushForthInterpreter.new([[:cdr,1,2],[3,4]]).step!.stack).to eq [[1,2],[4]]
  end

  it "should delete an empty list argument" do
    expect(PushForthInterpreter.new([[:cdr],[]]).step!.stack).to eq [[]]
  end
end


describe ":unit" do
  it "should disappear if the top item isn't a list" do
    expect(PushForthInterpreter.new([[:unit]]).step!.stack).to eq [[]]
  end

  it "should have a continuation form if the arg isn't a List" do
    expect(PushForthInterpreter.new([[:unit],1]).step!.stack).to eq [[:unit,1]]
  end

  it "should split the arg list into two, with the top item in the first" do
    expect(PushForthInterpreter.new([[:unit],[1,2]]).step!.stack).to eq [[],[1],[2]]
    expect(PushForthInterpreter.new([[:unit],[[1,2],3],4]).step!.stack).
      to eq [[],[[1,2]],[3],4]
  end

  it "should work when the :code stack is populated" do
    expect(PushForthInterpreter.new([[:unit,1,2],[3,4]]).step!.stack).to eq [[1,2],[3],[4]]
  end

  it "should create a new empty list when arg.length < 2" do
    expect(PushForthInterpreter.new([[:unit],[1]]).step!.stack).to eq [[],[1],[]]
    expect(PushForthInterpreter.new([[:unit],[]]).step!.stack).to eq [[],[],[]]
  end
end



describe ":concat (was ':cat')" do
  it "be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:concat)).to be true
  end

  it "should disappear if the top item isn't a list" do
    expect(PushForthInterpreter.new([[:concat]]).step!.stack).to eq [[]]
    expect(PushForthInterpreter.new([[:concat],1]).step!.stack).to eq [[],1]
  end

  it "should combine two lists" do
    expect(PushForthInterpreter.new([[:concat],[1,2],[3]]).step!.stack).
      to eq [[],[1,2,3]]
    expect(PushForthInterpreter.new([[:concat],[[1,2],3],[4]]).step!.stack).
      to eq [[],[[1,2],3,4]]
  end

  it "should use a continuation form when only one arg is a list" do
    expect(PushForthInterpreter.new([[:concat],[1,2],3,[4]]).step!.stack).
      to eq [[:concat, 3], [1, 2], [4]]
    expect(PushForthInterpreter.new([[:concat],1,[2,3],[4]]).step!.stack).
      to eq [[:concat, 1], [2, 3], [4]]

  end

  it "should work when the :code stack is populated" do
    expect(PushForthInterpreter.new([[:concat,1,2],[3,4],[5,6]]).step!.stack).
      to eq [[1,2],[3,4,5,6]]
  end

  it "should be comfortable 'concatenating' empty lists" do
    expect(PushForthInterpreter.new([[:concat],[],[1,2]]).step!.stack).to eq [[], [1, 2]]
    expect(PushForthInterpreter.new([[:concat],[1,2],[]]).step!.stack).to eq [[], [1, 2]]
    expect(PushForthInterpreter.new([[:concat],[],[]]).step!.stack).to eq [[], []]
  end
end

describe ":flip!" do
  it "be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:flip!)).to be true
  end

  it "should swap the :code and :data parts of the running stack" do
    expect(PushForthInterpreter.new([[:flip!],[1,2],3,[4]]).step!.stack).
      to eq [[[1,2],3,[4]]]
    expect(PushForthInterpreter.new([[:flip!,1,2,3],4,5,6]).step!.stack).
      to eq [[4, 5, 6], 1, 2, 3]
  end

  it "should work for empty :code lists and empty :data lists" do
    expect(PushForthInterpreter.new([[:flip!,1,2,3]]).step!.stack).
      to eq [[],1,2,3]
    expect(PushForthInterpreter.new([[:flip!],4,5,6]).step!.stack).
      to eq [[4, 5, 6]]
  end
end
