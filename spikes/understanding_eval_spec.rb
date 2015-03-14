require 'rspec'

    # stack
    # ----              
    # [[],[]]]               HALT  normal
    # [[],[1,2,3]]           HALT  normal
    # [[1,2,3],[]]           STEP  no split  
    # [[1,2,3],[1,2,3]]      STEP  no split


def nonemptyArray?(thing)
    thing.kind_of?(Array) &&
    !thing.empty?
end

def evaluable?(thing)
    nonemptyArray?(thing) &&
    nonemptyArray?(thing[0])
end

describe "evaluable" do
  it "should match Maarten's definition" do
    expect(evaluable? 4 ).to be false          # type error
    expect(evaluable? nil ).to be false        # type error

    expect(evaluable? []).to be false         # structural error
    expect(evaluable? [3]).to be false        # structural error

    expect(evaluable? [[],[1,2,3]] ).to be false # halted
    expect(evaluable? [[],[1,[2]]] ).to be false # halted

    expect(evaluable? [[],[]] ).to be false      # halted

    expect(evaluable? [[1,2,3],[]] ).to be true
    expect(evaluable? [[1,2,3],[1,2,3]] ).to be true

    expect(evaluable? [[[]],[]] ).to be true
  end
end

describe ":eval" do
  it "should do nothing if the argument isn't evaluable" do
    expect(eval 5).to eq 5
    expect(eval nil).to eq nil
    expect(eval [] ).to eq []
    expect(eval [1,2] ).to eq [1,2]
  end
end


def eval(thing)
    if evaluable?(thing)
        data = thing
        code = data.shift
        focus = code.shift
        if focus == :eval
            data[0] = eval(data[0]) unless data.empty?
        else
            data.unshift(focus)
        end
        thing = data.unshift(code)
    end
    return thing
end


describe "literals" do
  it "should move the top item on the 'code stack' to the 'data stack'" do
    expect(eval [[1], 2] ).to eq [[],1,2]
    expect(eval [[[1], 2]] ).to eq [[2], [1]]
    expect(eval [[1], 2,3,4] ).to eq [[],1,2,3,4]
    expect(eval [[[]], 1,2,3] ).to eq [[],[],1,2,3]
  end
end

describe "instructions" do
  it "should run :eval on the data stack item (but only if evaluable)" do
    expect(eval [[:eval]] ).to eq [[]]          # no arg
    expect(eval [[:eval],3] ).to eq [[],3]      # not evaluable
    expect(eval [[:eval],[3]] ).to eq [[],[3]]  # not evaluable
    expect(eval [[:eval],[[],4]] ).to eq [[],[[],4]]  # halted

  end

  it "should actually evaluate a valid 'stack' arg" do
    expect(eval [[:eval],[[1,2],3],4] ).to eq [[], [[2],1,3], 4]
    expect(eval [[:eval],[[1],2,3],4] ).to eq [[], [[], 1, 2, 3], 4]
    expect(eval [[:eval],[[:eval],[[1],2,3],4]] ).
        to eq [[], [[], [[], 1, 2, 3], 4]]
  end
end

