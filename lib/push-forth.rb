class Error
  attr_reader :string
  def initialize(string)
    @string = string
  end
end


class PushForth
  @@instructions = [:eval, :noop, :add, :subtract, :multiply, :divide, 
  :enlist, :cons, :pop, :dup, :swap, :rotate, :split, 
  :car, :cdr, :concat, :unit,
  :while]

  attr_accessor :stack


  def initialize(token_array=[])
    @stack = token_array
  end


  def nonemptyArray?(thing)
    thing.kind_of?(Array) &&
    !thing.empty?
  end


  def evaluable?(thing)
    nonemptyArray?(thing) &&
    nonemptyArray?(thing[0])
  end


  def instruction?(item)
    @@instructions.include?(item)
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


  def step!
    @stack = eval(@stack)
    return self
  end

  ### instructions
  ### arithmetic

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


  def divide(stack)
    return arithmetic(:divide, stack) do |a,b|
      (b.zero? ? Error.new("div0") : a/b)
    end
  end


  def multiply(stack)
    return arithmetic(:multiply, stack) do |a,b|
      a*b
    end
  end


  def subtract(stack)
    return arithmetic(:subtract, stack) do |a,b|
      a-b
    end
  end


  ### combinators

  def car(stack)
    if stack[1].kind_of?(Array)
      arg = stack.delete_at(1)
      stack.insert(1,arg[0]) unless arg.empty?
    end
    return stack
  end


  def cdr(stack)
    if stack[1].kind_of?(Array)
      arg = stack.delete_at(1)
      stack.insert(1,arg.drop(1)) unless arg.empty?
    end
    return stack
  end


  def concat(stack)
    if stack.length > 2
      arg1 = stack.delete_at(1)
      arg2 = stack.delete_at(1)
      k1,k2 = [arg1.kind_of?(Array),arg2.kind_of?(Array)]
      if k1 && k2
        stack.insert(1,arg1+arg2)
      elsif k1
        stack[0].unshift(:concat,arg2)
        stack.insert(1,arg1)
      elsif k2
        stack[0].unshift(:concat,arg1)
        stack.insert(1,arg2)
      else
        stack.insert(1,arg2,arg1)
      end
    end
    return stack
  end


  def cons(stack)
    if stack.length > 2
      arg1 = stack.delete_at(1)
      arg2 = stack.delete_at(1) # filled in
      if arg2.kind_of?(Array)
        stack.insert(1, arg2.unshift(arg1) )
      else
        stack[0].unshift(:cons,arg2)
        stack.insert(1,arg1)
      end
    end
    return stack
  end


  def dup(stack)
    stack.insert(1,stack[1]) unless stack.length < 2
    return stack
  end


  def enlist(stack)
    if stack[1].kind_of?(Array)
      stack[0] += stack.delete_at(1)
    end
    return stack
  end


  def pop(stack)
    if stack.length > 2
      stack.delete_at(1)
    end
    return stack
  end


  def rotate(stack)    
    stack[1],stack[2],stack[3] = stack[2],stack[3],stack[1] if stack.length > 3
    return stack
  end


  def split(stack)
    if stack.length > 1
      if stack[1].kind_of?(Array) && stack[1].length > 1 
        arg = stack.delete_at(1)
        out1 = arg[0]
        out2 = arg.drop(1)
        stack.insert(1,out1,out2)
      end
    end
    return stack
  end


  def swap(stack)
    stack[1],stack[2] = stack[2],stack[1] unless stack.length < 3
    return stack
  end


  def unit(stack)
    if stack[1].kind_of?(Array)
      arg = stack.delete_at(1)
      case arg.length
      when 0
        stack.insert(1,[],[])
      when 1
        stack.insert(1,arg,[])
      else
        stack.insert(1,[arg[0]],arg[1..-1])
      end
    end
    return stack
  end

  ### misc

  def noop(stack)
    return stack
  end


  def while(stack)
    if stack.length > 3
      arg1 = stack.delete_at(1)
      arg2 = stack.delete_at(1)
      arg3 = stack.delete_at(1)
      k1,k2,k3 = [arg1,arg2,arg3].collect {|a| a.kind_of?(Array)}
      if (k1 && k2 && k3) 
        if arg2.empty?
          stack.insert(1,arg2,arg3)
        else
          stack.insert(1,arg3)
          stack[0].unshift(:enlist)
          stack[0].unshift([arg1,:while])
          stack[0].unshift(*arg1)
        end
      else # for now; this could become a continuation
        stack.insert(1,arg1,arg2,arg3)
      end
    end
    return stack
  end
end