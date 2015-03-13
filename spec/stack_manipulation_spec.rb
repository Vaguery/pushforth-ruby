require 'rspec'
require_relative '../lib/push-forth'

describe ":dup" do
  it "be a recognized instruction" do
    expect(PushForth.new.instruction?(:dup)).to be true
  end

  it "should actually duplicate the top remaining item" do
    d = PushForth.new([[1,:dup]])
    expect(d.step.stack).to eq [[:dup],1]
    expect(d.step.stack).to eq [[],1,1]
  end

  it "should disappear if there's nothing on the stack" do
    d = PushForth.new([[:dup]])
    expect(d.step.stack).to eq [[]]
    expect(d.step.stack).to eq []
  end

  it "should work for fancy arguments" do
    d = PushForth.new([[:dup],[[[[[[1],2],3],4],5],6],7])
    expect(d.step.stack).to eq(
      [[], [[[[[[1], 2], 3], 4], 5], 6], [[[[[[1], 2], 3], 4], 5], 6], 7])
  end

  it "should work when the :code stack is populated" do
    d = PushForth.new([[:dup,1,2],3,4])
    expect(d.step.stack).to eq [[1,2],3,3,4]
  end
end


describe "swap" do
  it "be a recognized instruction" do
    expect(PushForth.new.instruction?(:swap)).to be true
  end

  it "should disappear unless there are two args" do
    expect(PushForth.new([[:swap]]).step.stack).to eq [[]]
    expect(PushForth.new([[:swap],1]).step.stack).to eq [[],1]
  end

  it "should swap things if there are at least two" do
    expect(PushForth.new([[:swap],1,2]).step.stack).to eq [[],2,1]
    expect(PushForth.new([[:swap],1,2,3,4]).step.stack).to eq [[],2,1,3,4]
  end

  it "should work for fancy items" do
    d = PushForth.new([[:swap],[[[[[[1],2],3],4],5],6],7])
    expect(d.step.stack).to eq [[], 7, [[[[[[1], 2], 3], 4], 5], 6]]
  end

  it "should work when the :code stack is populated" do
    d = PushForth.new([[:swap,1,2],3,4])
    expect(d.step.stack).to eq [[1,2],4,3]
  end
end


describe "rotate" do
  it "be a recognized instruction" do
    expect(PushForth.new.instruction?(:rotate)).to be true
  end

  it "should disappear unless there are three args" do
    expect(PushForth.new([[:rotate]]).step.stack).to eq [[]]
    expect(PushForth.new([[:rotate],1]).step.stack).to eq [[],1]
    expect(PushForth.new([[:rotate],1,2]).step.stack).to eq [[],1,2]
  end

  it "should rotate things if there are at least two" do
    expect(PushForth.new([[:rotate],1,2,3]).step.stack).to eq [[],2,3,1]
    expect(PushForth.new([[:rotate],1,2,3,4]).step.stack).to eq [[],2,3,1,4]
  end

  it "should work for fancy items" do
    d = PushForth.new([[:rotate],[[[[[[1],2],3],4],5],6],7,8,9])
    expect(d.step.stack).to eq [[], 7, 8, [[[[[[1], 2], 3], 4], 5], 6], 9]
  end

  it "should work when the :code stack is populated" do
    d = PushForth.new([[:rotate,1,2],3,4,5,6])
    expect(d.step.stack).to eq [[1,2],4,5,3,6]
  end
end


describe ":enlist (i combinator)" do
  it "be a recognized instruction" do
    expect(PushForth.new.instruction?(:enlist)).to be true
  end

  it "should disappear unless the top data item is a list" do
    expect(PushForth.new([[:enlist]]).step.stack).to eq [[]]
    expect(PushForth.new([[:enlist],1]).step.stack).to eq [[],1]
    expect(PushForth.new([[:enlist],1,[2]]).step.stack).to eq [[],1,[2]]
  end

  it "should queue a list from the data stack for execution" do
    expect(PushForth.new([[:enlist],[1,2],3]).step.stack).to eq(
      [[1,2],3])
    expect(PushForth.new([[:enlist],[1,[2]],3,4]).step.stack).to eq(
      [[1,[2]],3,4])
  end

  it "should work when the :code stack is populated" do
    d = PushForth.new([[:enlist,1,2],[3],4])
    expect(d.step.stack).to eq [[1,2,3],4]
  end

  it "should ignore a non-list item" do
    expect(PushForth.new([[:enlist,88],1,2,3]).step.stack).to eq(
      [[88],1,2,3])
  end
end


describe ":cons" do
  it "be a recognized instruction" do
    expect(PushForth.new.instruction?(:cons)).to be true
  end

  it "should won't work unless there are two args" do
    expect(PushForth.new([[:cons]]).step.stack).to eq [[]]
    expect(PushForth.new([[:cons],7]).step.stack).to eq [[],7]
  end

  it "uses a continuation form if the second arg isn't a list" do
    expect(PushForth.new([[:cons],1,2,3]).step.stack).to eq [[:cons, 2], 1, 3]
    expect(PushForth.new([[:cons, 2], 1, 3]).step.stack).to eq(
      [[:cons, 3, 2], 1])
  end

  it "prepends the first arg onto the second (a list)" do
    expect(PushForth.new([[:cons],1,[2]]).step.stack).to eq [[],[1,2]]
    expect(PushForth.new([[:cons],[1],[2]]).step.stack).to eq [[],[[1],2]]
  end


  it "should work when the :code stack is populated" do
    expect(PushForth.new([[:cons,1,2,3],4,[5]]).step.stack).to eq(
      [[1, 2, 3], [4, 5]])
  end
end


describe ":pop" do
  it "be a recognized instruction" do
    expect(PushForth.new.instruction?(:pop)).to be true
  end

  it "should disappear without an arg" do
    expect(PushForth.new([[:pop]]).step.stack).to eq [[]]
  end

  it "should delete the top item on the data stack" do
    expect(PushForth.new([[:pop],1,2,3]).step.stack).to eq [[], 2, 3]
    expect(PushForth.new([[:pop],[1, 2],3]).step.stack).to eq [[],3]
  end

  it "should work when the :code stack is populated" do
    expect(PushForth.new([[:pop,1,2,3],4,[5]]).step.stack).to eq(
      [[1, 2, 3], [5]])
  end
end


describe ":split" do
  it "be a recognized instruction" do
    expect(PushForth.new.instruction?(:split)).to be true
  end

  it "should disappear if the top item isn't a list" do
    expect(PushForth.new([[:split]]).step.stack).to eq [[]]
    expect(PushForth.new([[:split],1]).step.stack).to eq [[],1]
  end

  it "should unshift the top item of the top item on the data stack" do
    expect(PushForth.new([[:split],[1,2]]).step.stack).to eq [[], 1, [2]]
    expect(PushForth.new([[:split],[[1,2],3],4]).step.stack).to eq(
      [[], [1, 2], [3], 4])
  end

  it "should work when the :code stack is populated" do
    expect(PushForth.new([[:split,1,2],[3,4]]).step.stack).to eq [[1,2],3,[4]]
  end
end


