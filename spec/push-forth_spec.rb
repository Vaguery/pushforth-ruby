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
    it "should do nothing if the first item is an empty list" do
      d = PushForth.new([[],3])
      expect(d.step.stack).to eq [[],3]
    end

    it "should pull out the first sub-item the 1st item is a list" do
      d = PushForth.new([[1],2,3])
      expect(d.step.stack).to eq [[],1,2,3]
      expect(d.step.stack).to eq [[],1,2,3]
    end

    it "should only unpack one item at a time" do
      d = PushForth.new([[1,2,3],4,5])
      expect(d.step.stack).to eq [[2,3],1,4,5]
      expect(d.step.stack).to eq [[3],2,1,4,5]
      expect(d.step.stack).to eq [[],3,2,1,4,5]
      expect(d.step.stack).to eq [[],3,2,1,4,5]
    end

    it "should unpack items that are themselves lists" do
      d = PushForth.new([[[1],2,[3]],4,5])
      expect(d.step.stack).to eq [[2,[3]],[1],4,5]
    end

    it "should work for nested lists" do
      d = PushForth.new([[[[1]], [2]], 3])
      expect(d.step.stack).to eq [[[2]], [[1]], 3]
    end

    it "should do nothing if the first item isn't a list" do
      d = PushForth.new([1,2,3])
      expect(d.step.stack).to eq [1,2,3]
    end
  end

  describe "inside a script" do
    it "should do nothing the first item if an empty list" do
      d = PushForth.new([[:eval,3],[],1,2])
      expect(d.step.stack).to eq [[3],[],1,2]
      expect(PushForth.new([[:eval,3],[[]]]).step.stack).to eq [[3],[],[]]
    end

    it "should pull out the first literal item of an initial list" do
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




