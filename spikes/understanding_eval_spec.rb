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


def instruction?(thing)
    thing == :eval || thing == :add
end

def eval(state)
    if evaluable?(state)
        code = state[0]
        focus = code.shift
        if focus == :eval
            state[1] = eval(state[1]) if evaluable?(state[1])
        elsif instruction?(focus)
            state = self.method(focus).call(state)
        else
            state.insert(1,focus)
        end
    end
    return state
end


  def arithmetic(instruction, stack, &math_proc)
    unless stack.length < 3
        code = stack.shift
      arg1, arg2 = stack.shift(2)
      k1,k2 = [arg1.kind_of?(Numeric),arg2.kind_of?(Numeric)]
      if k1 && k2
        stack.unshift(math_proc.call(arg1,arg2))
      elsif k1
        code.unshift(instruction,arg2)
        stack.unshift(arg1)
      elsif k2
        code.unshift(instruction,arg1)
        stack.unshift(arg2)
      else
        stack.unshift(arg2,arg1)
      end
      stack.unshift(code)
    end
    return stack
  end


  def add(stack)
    return arithmetic(:add, stack) do |a,b|
      a+b
    end
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

  it "should work for math" do
    expect(eval [[:add],1,2] ).to eq [[], 3]
    expect(eval [[:add,1,2],3,4] ).to eq [[1, 2], 7]
    expect(eval [[:add]] ).to eq [[]]

  end

  it "should actually evaluate the arg as if it were a stack" do
    expect(eval [[:eval],[[1,2],3],4] ).to eq [[], [[2],1,3], 4]
    expect(eval [[:eval],[[1],2,3],4] ).to eq [[], [[], 1, 2, 3], 4]
    expect(eval [[:eval],[[:eval],[[1],2,3],4]] ).
        to eq [[], [[], [[], 1, 2, 3], 4]]

    expect(eval [[:eval],[[:add],3,4],5] ).
        to eq [[], [[], 7], 5]

    expect(eval [[:eval],7] ).to eq [[], 7]
    expect(eval [[:eval],[[7]]] ).to eq [[], [[], 7]]
  end
end

