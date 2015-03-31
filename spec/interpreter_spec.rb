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

  describe "timeout" do
    it "should be possible to set it from the #run call" do
      pf = PushForthInterpreter.new([[1],2]).run(5000,0.0)
      expect(pf.stack[1]).to be_a_kind_of(PushForth::Error)
      expect(pf.stack[1].string).to match /HALTED: .+ seconds elapsed/
    end
  end

  describe "step limit" do
    it "should be possible to set it from the #run call" do
      pf = PushForthInterpreter.new([[1],2]).run(0)
      expect(pf.stack[1]).to be_a_kind_of(PushForth::Error)
      expect(pf.stack[1].string).to match /HALTED: .+ steps reached/
    end
  end


  describe "run" do
    it "should step until it's not #evaluable?" do
      hasrun = PushForthInterpreter.new([[1,1,:add,1,1,1,:add,1,1,:add]]).run.stack
      expect(hasrun).to eq [[], 2, 2, 1, 2]
    end

    it "should step until its counter runs out" do
      hasrun = PushForthInterpreter.new([[[[]],[:eval,:dup,:car],:while],[[16,1.0,:divide]]]).run
      expect(hasrun.stack).to eq [[], [], [[], 0.0625]]
      expect(hasrun.steps).to eq 24
    end

    it "should step until the timer runs out" do
      slow = PushForthInterpreter.new([[1,2,3,4,5,6,7,8,9,10]])
      slow.run(5000,0.000000001)
      expect(slow.stack[1]).to be_a_kind_of(Error)
      expect(slow.stack[1].string).to match /HALTED: .+ seconds elapsed/
    end
  end

  describe ":deep_copy" do
    it "should just return simple types" do
      pf = PushForthInterpreter.new
      expect(deep_copy(9).object_id).to eq 9.object_id
      expect(deep_copy(false).object_id).to eq false.object_id
      expect(deep_copy(1.23).object_id).to eq (1.23).object_id
      expect(deep_copy(:foo).object_id).to eq :foo.object_id
    end

    it "should change the object_id of Arrays" do
      pf = PushForthInterpreter.new
      expect(deep_copy([]).object_id).not_to eq [].object_id
      expect(deep_copy([1,2,3]).object_id).not_to eq [1,2,3].object_id
      expect(deep_copy([1,[2,3]]).object_id).not_to eq [1,[2,3]].object_id
    end

    it "should change the object_id of deep_copyable things inside Arrays" do
      pf = PushForthInterpreter.new
      expect(deep_copy([1,[2,3]])[0].object_id).to eq [1,[2,3]][0].object_id
      expect(deep_copy([1,[2,3]])[1].object_id).not_to eq [1,[2,3]][1].object_id
    end

    it "should change the object_id of Dictionary items" do
      pf = PushForthInterpreter.new
      d = Dictionary.new
      expect(deep_copy([d])[0].object_id).not_to eq d.object_id
    end

    it "should change the object_id of deep_copyable keys in Dictionaries" do
      pf = PushForthInterpreter.new
      d = Dictionary.new
      k1 = [1,2,3]
      v1 = [:foo,[4,5,6]]
      d.set(k1,v1)
      expect(deep_copy(d).keys[0].object_id).not_to eq d.keys[0].object_id
      expect(deep_copy(d).get(d.keys[0]).object_id).not_to eq d.get(d.keys[0]).object_id
    end
  end

end