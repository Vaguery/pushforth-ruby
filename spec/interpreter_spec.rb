require 'spec_helper'


describe PushForth do
  describe "initialization" do
    it "should work with a default" do
      expect(PushForthInterpreter.new().stack).to eq []
    end
  end

  describe "#size function" do
    it "should count items in the stack" do
      expect(PushForthInterpreter.new.size [1,2,3,4,5]).to eq 6
      expect(PushForthInterpreter.new.size []).to eq 1
      expect(PushForthInterpreter.new.size [[],[]]).to eq 3
      expect(PushForthInterpreter.new.size [1,[2,[3,[4]]]]).to eq 8
      expect(PushForthInterpreter.new.size Dictionary.new({1 => 2, 3 => 4})).to eq 5
      expect(PushForthInterpreter.new.size [:foo,:bar]).to eq 3
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
      pf = PushForthInterpreter.new([[1],2]).run(time_limit:0.0)
      expect(pf.stack[1]).to be_a_kind_of(PushForth::Error)
      expect(pf.stack[1].string).to match /HALTED: .+ seconds elapsed/
    end
  end

  describe "step limit" do
    it "should be possible to set it from the #run call" do
      pf = PushForthInterpreter.new([[1],2]).run(step_limit:0)
      expect(pf.stack[1]).to be_a_kind_of(PushForth::Error)
      expect(pf.stack[1].string).to match /HALTED: .+ steps reached/
    end
  end

  describe "size limit" do
    it "should be possible to set it from the #run call" do
      pf = PushForthInterpreter.new([[1,2,3,4,5,6,7,8,9],10]).run(size_limit:11)
      expect(pf.stack[1]).to be_a_kind_of(PushForth::Error)
      expect(pf.stack[1].string).to match /HALTED: \d+ points/
    end
  end

  describe "max_depth" do
    it "should return the (max) depth of a List" do
      pf = PushForthInterpreter.new
      expect(pf.max_depth([])).to eq 1
      expect(pf.max_depth(1)).to eq 0
      expect(pf.max_depth([1])).to eq 1
      expect(pf.max_depth([1,2])).to eq 1
      expect(pf.max_depth([1,[2]])).to eq 2
      expect(pf.max_depth([1,[[2]]])).to eq 3
      expect(pf.max_depth([[[1],[[2]]]])).to eq 4
    end

    it "should return the (max) depth of any key or value of a Dictionary" do
      pf = PushForthInterpreter.new
      d = Dictionary.new()
      expect(pf.max_depth(d)).to eq 1
      d.set(1,2)
      expect(pf.max_depth(d)).to eq 1
      d.set([1],2)
      expect(pf.max_depth(d)).to eq 2
      d.set(3,[[[1],[[2]]]]) # max_depth = 4
      expect(pf.max_depth(d)).to eq 5
    end
  end

  describe "depth limit" do
    it "should be possible to set it from the #run call" do
      pf = PushForthInterpreter.new([[:add],[[[[[[[[[[[[1]]]]]]]]]]]],2,3]).run(depth_limit:3)
      expect(pf.stack[1]).to be_a_kind_of(PushForth::Error)
      expect(pf.stack[1].string).to match /HALTED: \d+ exceeds depth limit/
    end
  end


  describe "run" do
    it "should step until it's not #evaluable?" do
      hasrun = PushForthInterpreter.new([[1,1,:add,1,1,1,:add,1,1,:add]]).run.stack
      expect(hasrun).to eq [[], 2, 2, 1, 2]
    end

    it "should step until its counter runs out" do
      hasrun = PushForthInterpreter.new([[[[]],[:eval,:dup,:car],:while],[[16.0,1.0,:divide]]]).run
      expect(hasrun.stack).to eq [[], [], [[], 0.0625]]
      expect(hasrun.steps).to eq 24
    end

    it "should step until the timer runs out" do
      slow = PushForthInterpreter.new([[1,2,3,4,5,6,7,8,9,10]])
      slow.run(time_limit:0.000000001)
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

  describe ":later" do
    it "should take the top item from code and put it at the bottom of the code" do
      expect(PushForthInterpreter.new([[:later,1,2,3],[4,5,6]]).step!.stack).
        to eq [[2, 3, 1], [4, 5, 6]]
      expect(PushForthInterpreter.new([[:later]]).step!.stack).
        to eq [[]]
    end
  end

  describe ":henceforth" do
    it "should append `:henceforth (copy of code stack)` to the code stack" do
      expect(PushForthInterpreter.new([[:henceforth,1,2,3],[4,5,6]]).step!.stack).
        to eq [[1, 2, 3, :henceforth, 1, 2, 3], [4, 5, 6]]
      expect(PushForthInterpreter.new([[:henceforth]]).step!.stack).
        to eq [[:henceforth]]
    end

    it "should create deep_copies of things" do
      e = Dictionary.new()
      d = Dictionary.new(1 => e)
      pf = PushForthInterpreter.new([[:henceforth,d],[4,5,6]]).step!
      expect(pf.stack[0][2].object_id).not_to eq d.object_id
      expect(pf.stack[0][2].get(1).object_id).not_to eq d.get(1).object_id
    end
  end

  describe "do_times" do
    it "should disappear if there aren't 2 arguments" do
      expect(PushForthInterpreter.new([[:do_times],1]).step!.stack).
        to eq [[], 1]
      expect(PushForthInterpreter.new([[:do_times]]).step!.stack).
        to eq [[]]
    end

    it "should do nothing if arg1 is an Integer 0 or less" do
      expect(PushForthInterpreter.new([[:do_times],0,[4,4]]).step!.stack).
        to eq [[], [4,4]]
      expect(PushForthInterpreter.new([[:do_times],-10,[4,4]]).step!.stack).
        to eq [[], [4,4]]
    end

    it "should run the top List code if arg1 is an Integer 1 or more, and count down" do
      expect(PushForthInterpreter.new([[:do_times],1,[4,4]]).step!.stack).
        to eq [[4, 4, [4, 4], 0, :do_times]]
      expect(PushForthInterpreter.new([[:do_times],123,[4,4]]).step!.stack).
        to eq [[4, 4, [4, 4], 122, :do_times]]
    end

    it "should set aside the integer if arg2 is not a List" do
      expect(PushForthInterpreter.new([[:do_times],1,4]).step!.stack).
        to eq [[:do_times, 4], 1]
    end

    it "should set aside the List if arg1 is not an Integer" do
      expect(PushForthInterpreter.new([[:do_times],:add,[8],11]).step!.stack).
        to eq [[:swap, :do_times, :add], [8], 11]
    end
  end


  describe ":wrapitup" do
    it "should remove all copies of :henceforth from the code stack" do
      expect(PushForthInterpreter.new([[:wrapitup, 1, 2, 3, :henceforth, 1, 2, 3], [4, 5, 6]]).step!.stack).
        to eq [[1, 2, 3, 1, 2, 3], [4, 5, 6]]
    end

    it "should remove all copies of :do_times from the code stack" do
      expect(PushForthInterpreter.new([[:wrapitup, 1, 2, 3, :do_times, 1, 2, 3]]).step!.stack).
      to eq [[1, 2, 3, 1, 2, 3]]
    end

    it "should remove all copies of :while from the code stack" do
      expect(PushForthInterpreter.new([[:wrapitup, 1, 2, 3, :while, 1, 2, 3]]).step!.stack).
      to eq [[1, 2, 3, 1, 2, 3]]
    end

    it "should work when empty too" do
      expect(PushForthInterpreter.new([[:wrapitup], [4, 5, 6]]).step!.stack).
        to eq [[], [4, 5, 6]]
    end
  end

  describe ":snapshot" do
    it "should make a complete copy of the entire stack on the data stack" do
      expect(PushForthInterpreter.new([[:snapshot,1,[2,3]],4,5,6]).step!.stack).
        to eq [[1, [2, 3]], [[1, [2, 3]], 4, 5, 6], 4, 5, 6]
    end

    it "should work for an empty data stack" do
      expect(PushForthInterpreter.new([[:snapshot,1]]).step!.stack).
        to eq [[1], [[1]]]
    end

    it "should work when empty" do
      expect(PushForthInterpreter.new([[:snapshot]]).step!.stack).
        to eq  [[], [[]]]
    end
  end

  describe ":again" do
    it "should insert a complete copy of the data stack on the bottom of the code stack" do
      expect(PushForthInterpreter.new([[:again,1,[2,3]],4,5,6]).step!.stack).
        to eq [[1, [2, 3], 4, 5, 6], 4, 5, 6]
    end

    it "should work when data is empty" do
      expect(PushForthInterpreter.new([[:again,1]]).step!.stack).
        to eq [[1]]
    end


    it "should work when empty" do
      expect(PushForthInterpreter.new([[:again]]).step!.stack).
        to eq  [[]]
    end
  end

end