require 'rspec'
require_relative '../lib/push-forth'
include PushForth

# see https://www.lri.fr/~hansen/proceedings/2013/GECCO/companion/p1635.pdf


describe PushForth do
  describe "initialization" do
    it "should work with a default" do
      expect(PushForthInterpreter.new().stack).to eq []
    end
  end


describe "evaluable" do
  it "should match Maarten's definition" do
    expect(PushForthInterpreter.new().evaluable? 4 ).to be false          # type error
    expect(PushForthInterpreter.new().evaluable? nil ).to be false        # type error
    expect(PushForthInterpreter.new().evaluable? []).to be false         # structural error
    expect(PushForthInterpreter.new().evaluable? [3]).to be false        # structural error
    expect(PushForthInterpreter.new().evaluable? [[],[1,2,3]] ).to be false # halted
    expect(PushForthInterpreter.new().evaluable? [[],[1,[2]]] ).to be false # halted
    expect(PushForthInterpreter.new().evaluable? [[],[]] ).to be false      # halted
    expect(PushForthInterpreter.new().evaluable? [[1,2,3],[]] ).to be true
    expect(PushForthInterpreter.new().evaluable? [[1,2,3],[1,2,3]] ).to be true
    expect(PushForthInterpreter.new().evaluable? [[[]],[]] ).to be true
  end
end


  describe "step!" do
    it "should do nothing unless evaluable" do
      expect(PushForthInterpreter.new([1,2,3]).step!.stack).to eq [1,2,3]
      expect(PushForthInterpreter.new([[],1,2,3]).step!.stack).to eq [[],1,2,3]
      expect(PushForthInterpreter.new().step!.stack).to eq []
    end

    it "it should unpack a literal from the code stack (if evaluable)" do
      expect(PushForthInterpreter.new([[1],2,3]).step!.stack).to eq [[],1,2,3]
      expect(PushForthInterpreter.new([[1,2,3]]).step!.stack).to eq [[2,3],1]
      expect(PushForthInterpreter.new([[[1],2],3]).step!.stack).to eq [[2],[1],3]
    end

    it "it should execute an instruction it finds on the code stack" do
      expect(PushForthInterpreter.new([[:noop,1,2],3]).step!.stack).to eq [[1,2],3]
    end

    it "should act as Maarten indicates in his paper" do
      expect(PushForthInterpreter.new([[1,1,:add]]).step!.stack).to eq [[1, :add], 1]
    end
  end

  describe "the :eval instruction" do
    it "should run an :eval it finds on the code stack" do
      expect(PushForthInterpreter.new([[:add,1,2],3,4]).step!.stack).to eq [[1,2], 7]
      # just making sure it's consistent
      d = PushForthInterpreter.new([[:eval],[[:add,1,2],3,4]])
      expect(d.step!.stack).to eq [[], [[1, 2], 7]]
    end

    it "should act as Maarten indicates in his paper" do
      expected = PushForthInterpreter.new([[1,1,:add]]).step!.stack # [[1, :add], 1]
      # just checking
      expect(PushForthInterpreter.new().evaluable?([[1,1,:add]])).to be true
      expect(PushForthInterpreter.new([[:eval],[[1,1,:add]]]).step!.stack).
        to eq [[],expected]
    end
  end
end