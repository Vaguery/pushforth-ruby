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
  it "should do nothing if the first item is an empty list" do
    d = PushForth.new([[],3])
    expect(d.eval.stack).to eq [3]
  end

  it "should move across the next token if it's a literal" do
    d = PushForth.new([[1],2,3])
    expect(d.eval.stack).to eq [[],1,2,3]
    expect(d.eval.stack).to eq [1,2,3]
  end

  it "should keep the remaining list items if the list isn't empty" do
    d = PushForth.new([[1,2,3],4,5])
    expect(d.eval.stack).to eq [[2,3],1,4,5]
  end

  it "should move across lists as well" do
    d = PushForth.new([[[1],2,[3]],4,5])
    expect(d.eval.stack).to eq [[2,[3]],[1],4,5]
  end

  it "should do nothing if the first item isn't a list" do
    d = PushForth.new([1,2,3])
    expect(d.eval.stack).to eq [1,2,3]
  end
end

describe ":dup" do
  it "should recognize :dup as an instruction" do
    d = PushForth.new([[1,:dup]])
    expect(d.eval.stack).to eq [[:dup], 1]
    expect(d.eval.stack).to eq [1, 1]
  end

  it "should not do anything if there's nothing on the stack" do
    d = PushForth.new([[:dup]])
    expect(d.eval.stack).to eq []
  end

  it "should work for fancy arguments" do
    d = PushForth.new([[:dup],[[[[[[1],2],3],4],5],6],7])
    expect(d.eval.stack).to eq(
      [[[[[[[1], 2], 3], 4], 5], 6], [[[[[[1], 2], 3], 4], 5], 6], 7])
  end
end