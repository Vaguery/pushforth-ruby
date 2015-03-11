require 'rspec'
require_relative '../lib/push-forth'

describe "initialization" do
  it "should have an empty stack if no script is passed in" do
    expect(PushForth.new().stack).to eq [[]]
  end

  it "should set the @stack if an array is passed in" do
    expect(PushForth.new([[1],2]).stack).to eq [[1],2]
  end
end

describe "eval" do
  # see https://www.lri.fr/~hansen/proceedings/2013/GECCO/companion/p1635.pdf
  it "should delete the first item if it is an empty list" do
    d = PushForth.new([[],3])
    expect(d.eval.stack).to eq [3]
  end

  it "should pull out the first sub-item the 1st item is a list" do
    d = PushForth.new([[1],2,3])
    expect(d.eval.stack).to eq [[],1,2,3]
    expect(d.eval.stack).to eq [1,2,3]
  end

  it "should only unpack one item at a time" do
    d = PushForth.new([[1,2,3],4,5])
    expect(d.eval.stack).to eq [[2,3],1,4,5]
    expect(d.eval.stack).to eq [[3],2,1,4,5]
    expect(d.eval.stack).to eq [[],3,2,1,4,5]
    expect(d.eval.stack).to eq [3,2,1,4,5]
  end

  it "should unpack items that are themselves lists" do
    d = PushForth.new([[[1],2,[3]],4,5])
    expect(d.eval.stack).to eq [[2,[3]],[1],4,5]
  end

  it "should do nothing if the first item isn't a list" do
    d = PushForth.new([1,2,3])
    expect(d.eval.stack).to eq [1,2,3]
  end
end


describe ":dup" do
  it "be a recognized instruction" do
    expect(PushForth.new.instruction?(:dup)).to be true
  end

  it "should actually duplicate the top remaining item" do
    d = PushForth.new([[1,:dup]])
    expect(d.eval.stack).to eq [[:dup], 1]
    expect(d.eval.stack).to eq [1, 1]
  end

  it "should disappear if there's nothing on the stack" do
    d = PushForth.new([[:dup]])
    expect(d.eval.stack).to eq []
  end

  it "should work for fancy arguments" do
    d = PushForth.new([[:dup],[[[[[[1],2],3],4],5],6],7])
    expect(d.eval.stack).to eq(
      [[[[[[[1], 2], 3], 4], 5], 6], [[[[[[1], 2], 3], 4], 5], 6], 7])
  end
end