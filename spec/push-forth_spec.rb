require 'rspec'
require_relative '../lib/push-forth'

# see https://www.lri.fr/~hansen/proceedings/2013/GECCO/companion/p1635.pdf


describe "initialization" do
  it "should have an empty stack if no script is passed in" do
    expect(PushForth.new().stack).to eq [[]]
  end

  it "should set the @stack if an array is passed in" do
    expect(PushForth.new([[1],2]).stack).to eq [[1],2]
  end
end

describe "step (eval)" do
  describe "at the interpreter level" do
    it "should delete the first item if it is an empty list" do
      d = PushForth.new([[],3])
      expect(d.step.stack).to eq [3]
    end

    it "should pull out the first sub-item the 1st item is a list" do
      d = PushForth.new([[1],2,3])
      expect(d.step.stack).to eq [[],1,2,3]
      expect(d.step.stack).to eq [1,2,3]
    end

    it "should only unpack one item at a time" do
      d = PushForth.new([[1,2,3],4,5])
      expect(d.step.stack).to eq [[2,3],1,4,5]
      expect(d.step.stack).to eq [[3],2,1,4,5]
      expect(d.step.stack).to eq [[],3,2,1,4,5]
      expect(d.step.stack).to eq [3,2,1,4,5]
    end

    it "should unpack items that are themselves lists" do
      d = PushForth.new([[[1],2,[3]],4,5])
      expect(d.step.stack).to eq [[2,[3]],[1],4,5]
    end

    it "should do nothing if the first item isn't a list" do
      d = PushForth.new([1,2,3])
      expect(d.step.stack).to eq [1,2,3]
    end
  end

  describe "inside a script" do
    it "should delete the first item if an empty list" do
      d = PushForth.new([[:eval,3],[],1,2])
      expect(d.step.stack).to eq [[3],1,2]
    end

    it "should pull out the first item of an initial list" do
      d = PushForth.new([[:eval],[1,2],3,4])
      expect(d.step.stack).to eq [[],[2],1,3,4]
    end

    it "should pull out entire items even if lists" do
      d = PushForth.new([[:eval],[[1],2],3,4])
      expect(d.step.stack).to eq [[],[2],[1],3,4]
    end

    it "should do nothing if the first item isn't a list" do
      d = PushForth.new([[:eval],1,2,3])
      expect(d.step.stack).to eq [[],1,2,3]
    end

  end
end



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
end