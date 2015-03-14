require 'rspec'
require_relative '../lib/push-forth'

# see https://www.lri.fr/~hansen/proceedings/2013/GECCO/companion/p1635.pdf


describe PushForth do
  describe "initialization" do
    it "should work with a default" do
      expect(PushForth.new().data).to eq []
    end

    it "should store an array passed in" do
      expect(PushForth.new([1,2,3]).data).to eq [1,2,3]
    end

    it "should leave @code empty" do
      expect(PushForth.new([1,2,3]).code).to eq nil
    end
  end


  describe "evaluable?" do
    it "should be false when @data is empty" do
      expect(PushForth.new().evaluable?).to be false
    end

    it "should be false when @data[0] is not an array" do
      expect(PushForth.new([1,2,3]).evaluable?).to be false
    end

    it "should be false when @data[0] is an empty array" do
      expect(PushForth.new([[],1,2,3]).evaluable?).to be false
    end

    it "should be true when @data[0] is a non-empty array" do
      expect(PushForth.new([[1,2],3]).evaluable?).to be true
    end
  end


  describe "step!" do
    it "should do nothing unless evaluable" do
      expect(PushForth.new([1,2,3]).step!.stack).to eq [1,2,3]
      expect(PushForth.new([[],1,2,3]).step!.stack).to eq [[],1,2,3]
      expect(PushForth.new().step!.stack).to eq []
    end

    it "it should unpack a literal from the code stack (if evaluable)" do
      expect(PushForth.new([[1],2,3]).step!.stack).to eq [[],1,2,3]
      expect(PushForth.new([[1,2,3]]).step!.stack).to eq [[2,3],1]
      expect(PushForth.new([[[1],2],3]).step!.stack).to eq [[2],[1],3]
    end

    it "it should execute an instruction it finds on the code stack" do
      expect(PushForth.new([[:noop,1,2],3]).step!.stack).to eq [[1,2],3]
    end

  end

  describe "the :eval instruction" do
    it "should run an :eval it finds on the code stack" do
      expect(PushForth.new([[:add], 1, 2]).step!.stack).to eq [[], 3]
      # just making sure

      d = PushForth.new([[:eval], [[:add], 1, 2], 4])
      expect(d.step!.stack).to eq [[], [[], 3], 4]
    end


  end


end