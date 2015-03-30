module PushForth


  class Error
    attr_reader :string
    def initialize(string)
      @string = string
    end
  end


  class Dictionary
    attr_accessor :contents

    def initialize(hash = {})
      @contents = hash
    end

    def set(key,value)
      value = value.clone if value.kind_of?(Array) || value.kind_of?(Dictionary)
      contents[key] = value
    end

    def get(key)
      return contents[key] || Error.new("key not found")
    end

    def eql?(other)
      return @contents.eql?(other.contents)
    end

    def keys
      @contents.keys
    end

    def clone
      copy = Dictionary.new()
      self.keys.each do |k|
        safe_key = deep_copy(k)
        safe_val = deep_copy(@contents[k])
        copy.contents[safe_key] = safe_val
      end
      return copy
    end
  end


  def deep_copy(item)
    case item
    when Dictionary
      item.clone
    when Array
      item.collect {|i| deep_copy(i)}
    else
      item
    end
  end


  class PushForthInterpreter

    def self.instructions
      return @@instructions
    end

    @@instructions = [:eval, :noop, :add, :subtract, :multiply, :divide, :divmod, 
      :enlist, :cons, :pop, :dup, :swap, :rotate, :split, 
      :car, :cdr, :concat, :unit, :flip!, :reverse,
      :map, :while, :until0, :leafmap,
      :and, :or, :not, :if, :which,
      :set, :get, :dict,
      :>, :<, :≥, :≤, :==, :≠,
      :type, :types, :is_a?, :gather_all, :gather_same,
      :args]

    @@types = [:BooleanType, :ComplexType, :DictionaryType, :ErrorType, :FloatType, :InstructionType, :IntegerType, :ListType, :NumberType, :RationalType, :TypeType, :UnknownType]


    @@type_tree = {:BooleanType => [:BooleanType],
                   :ComplexType => [:ComplexType,:NumberType],
                   :DictionaryType => [:DictionaryType],
                   :ErrorType => [:ErrorType],
                   :FloatType => [:FloatType,:NumberType],
                   :InstructionType => [:InstructionType],
                   :IntegerType => [:IntegerType,:NumberType],
                   :ListType => [:ListType],
                   :NumberType => [:NumberType],
                   :RationalType => [:RationalType,:NumberType],
                   :TypeType => [:TypeType],
                   :UnknownType => [:UnknownType]
                 }

    ## Doesn't include Symbol, since that's trickier
    @@classes_to_types = {Array => :ListType, Complex => :ComplexType, PushForth::Dictionary => :DictionaryType, PushForth::Error => :ErrorType, FalseClass => :BooleanType, Fixnum => :IntegerType, Float => :FloatType, Rational => :RationalType, TrueClass => :BooleanType}


    attr_accessor :stack,:steps,:args

    def initialize(token_array=[],args=[])
      @stack = token_array
      @steps = 0
      @args = args
    end

    def get_args
      @args
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


    def halted?
      !evaluable?(@stack)      
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
      @steps += 1
      @stack = eval(@stack)
      return self
    end


    def run
      while evaluable?(@stack) && @steps < 5000
        self.step!
      end
      self
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


    def divmod(stack)
      return arithmetic(:divmod, stack) do |a,b|
        case 
        when b.kind_of?(Complex)
          Error.new("divmod type error")
        when b.zero?
          Error.new("div0")
        else
          a.divmod(b)
        end
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

    ### comparison 

    def >(stack)
      return arithmetic(:>, stack) do |a,b|
        if a.kind_of?(Complex) || b.kind_of?(Complex)
          Error.new("compared Complex values")
        else
           a > b
        end
      end
    end

    def <(stack)
      return arithmetic(:<, stack) do |a,b|
        if a.kind_of?(Complex) || b.kind_of?(Complex)
          Error.new("compared Complex values")
        else
           a > b
        end
      end
    end

    def ≥(stack)
      return arithmetic(:≥, stack) do |a,b|
        if a.kind_of?(Complex) || b.kind_of?(Complex)
          Error.new("compared Complex values")
        else
           a >= b
        end
      end
    end

    def ≤(stack)
      return arithmetic(:≤, stack) do |a,b|
        if a.kind_of?(Complex) || b.kind_of?(Complex)
          Error.new("compared Complex values")
        else
           a <= b
        end
      end
    end

    def ==(stack)
      return arithmetic(:==, stack) do |a,b|
        a == b
      end
    end

    def ≠(stack)
      return arithmetic(:≠, stack) do |a,b|
        a != b
      end
    end

    ### boolean

    def boolean?(thing)
      thing == true || thing == false
    end


    def boolean_arity_2(instruction, stack, &math_proc)
      unless stack.length < 3
          code = stack.shift
        arg1, arg2 = stack.shift(2)
        k1,k2 = [boolean?(arg1),boolean?(arg2)]
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


    def and(stack)
      return boolean_arity_2(:and, stack) do |a,b|
        a && b
      end
    end


    def or(stack)
      return boolean_arity_2(:or, stack) do |a,b|
        a || b
      end
    end


    def not(stack)
      if boolean?(stack[1])
        stack[1] = !stack[1]
      end
      return stack
    end


    def if(stack)
      if stack.length > 2
          code = stack.shift
        arg1, arg2 = stack.shift(2)
        if boolean?(arg1)
          stack.unshift(arg2) if arg1
        else
          code.unshift(:if,arg1)
        end
        stack.unshift(code)
      end
      return stack
    end


    def which(stack)
      if stack.length > 3
          code = stack.shift
        arg1, arg2, arg3 = stack.shift(3)
        if boolean?(arg1)
          stack.unshift(arg1 ? arg2 : arg3) 
        else
          code.unshift(:which,arg1)
          stack.unshift(arg2,arg3)
        end
        stack.unshift(code)
      end
      return stack
    end

    ### type

    def dictionary?(thing)
      thing.kind_of? Dictionary
    end


    def list?(thing)
      thing.kind_of? Array
    end


    def recognized_ruby?(item)
      @@classes_to_types.keys.include? item.class
    end


    def is_a?(stack)
      if stack.length > 2
        code = stack.shift
        arg1,arg2 = stack.shift(2)
        if pushforth_type(arg1) == :TypeType
          alternatives = pushforth_types(arg2)
          stack.unshift(alternatives.include?(arg1))
        else
          code.unshift(:is_a?, arg1)
          stack.unshift(arg2)
        end
        stack.unshift(code)
      end
      return stack
    end


    def pushforth_type(item)
      case
      when item.kind_of?(Symbol)
        if @@instructions.include?(item)
          :InstructionType
        elsif @@types.include?(item)
          :TypeType
        else
          :UnknownType
        end
      when recognized_ruby?(item)
        @@classes_to_types[item.class]
      else
        :UnknownType
      end
    end


    def pushforth_types(item)
      @@type_tree[pushforth_type(item)]
    end


    def type(stack)
      if stack.length > 1
        code = stack.shift
        arg = stack.shift
        stack.unshift pushforth_type(arg)
        stack.unshift(code)
      end
      return stack
    end

    def types(stack)
      if stack.length > 1
        code = stack.shift
        arg = stack.shift
        stack.unshift pushforth_types(arg)
        stack.unshift(code)
      end
      return stack
    end

    def gather_all(stack)
      if stack.length > 1
        code = stack.shift
        arg = stack.shift
        if pushforth_type(arg) == :TypeType
          hits,misses = stack.partition {|i| @@type_tree[pushforth_type(i)].include?(arg)}
          stack = misses.unshift(hits)
        else
          stack.unshift(arg)
        end
        stack.unshift(code)
      end
      return stack
    end


    def gather_same(stack)
      if stack.length > 1
        code = stack.shift
        arg = stack.shift
        hits,misses = stack.partition {|i| pushforth_type(i)==pushforth_type(arg)}
        stack = misses.unshift(hits.unshift(arg))
        stack.unshift(code)
      end
      return stack
    end


    ### dictionary


    def get(stack)
      if stack.length > 2
        code = stack.shift
        arg1,arg2 = stack.shift(2)
        if dictionary?(arg1)
          stack.unshift(arg1.get(arg2),arg1)
        else
          code.unshift(:get,arg1)
          stack.unshift(arg2)
        end
        stack.unshift(code)
      end
      return stack
    end


    def set(stack)
      if stack.length > 3
        code = stack.shift
        arg1,arg2,arg3 = stack.shift(3)
        if dictionary?(arg1)
          arg1.set(arg2,arg3)
          stack.unshift(arg1)
        else
          code.unshift(:set,arg1)
          stack.unshift(arg2,arg3)
        end
        stack.unshift(code)
      end
      return stack
    end


    def dict(stack)
      return stack.insert(1,PushForth::Dictionary.new)
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
        arg2 = stack.delete_at(1)
        if arg2.kind_of?(Array)
          stack.insert(1, arg2.unshift(deep_copy(arg1)) )
        else
          stack[0].unshift(:cons,arg2)
          stack.insert(1,arg1)
        end
      end
      return stack
    end


    def dup(stack)
      stack.insert(1,deep_copy(stack[1])) unless stack.length < 2
      return stack
    end


    def enlist(stack)
      if stack[1].kind_of?(Array)
        stack[0] += stack.delete_at(1)
      end
      return stack
    end


    def flip!(stack)
      old_code = stack.shift
      stack = [stack] + old_code 
      return stack
    end


    def pop(stack)
      if stack.length > 2
        stack.delete_at(1)
      end
      return stack
    end


    def reverse(stack)
      if stack.length > 1
        code = stack.shift
        stack[0].reverse! if list?(stack[0])
        stack.unshift(code)
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

    def args(stack)
      code = stack.shift
      stack.unshift(*deep_copy(@args))
      stack.unshift(code)
      return stack
    end


    def noop(stack)
      return stack
    end

    ### functional

    def append_to_leaves(tree_array,suffix_array)
      result = []
      tree_array.each do |item|
        if item.kind_of?(Array)
          result << append_to_leaves(deep_copy(item),deep_copy(suffix_array))
        else
          result += ([deep_copy(item)] + deep_copy(suffix_array))
        end
      end
      return result
    end


    def leafmap(stack)
      if stack.length > 2
        code = stack.shift
        arg1,arg2 = stack.shift(2)
        if arg1.kind_of?(Array) && arg2.kind_of?(Array)
          mapped = append_to_leaves(deep_copy(arg1),deep_copy(arg2))
        elsif arg2.kind_of?(Array)
          mapped = deep_copy(arg2).unshift(deep_copy(arg1))
        else
          mapped = append_to_leaves([deep_copy(arg1)],[deep_copy(arg2)])
        end
        code.unshift(*mapped)
        stack.unshift(code)
      end
      return stack
    end


    def map(stack)
      if stack.length > 2
        code = stack.shift
        arg1,arg2 = stack.shift(2)
        if arg1.kind_of?(Array) && arg2.kind_of?(Array)
          mapped = arg1.collect do |i|
            [i] + deep_copy(arg2)
          end
          mapped = mapped.flatten(1)
        elsif arg2.kind_of?(Array)
          mapped = arg2.unshift(arg1)
        else
          mapped = [arg1,arg2]
        end
        code.unshift(*mapped)
        stack.unshift(code)
      end
      return stack
    end


    def until0(stack)
      if stack.length > 3
        code = stack.shift
        arg1,arg2,arg3 = stack.shift(3)
        match1 = arg1.kind_of?(Integer) && arg1 >= 0
        match2 = arg2.kind_of?(Array)
        match3 = arg3.kind_of?(Array)
        if match1
          if match2
            if match3
              if arg1 > 0
                code.unshift(*deep_copy(arg3),arg3,arg2,arg1-1,:until0)
              elsif arg1 == 0
                code.unshift(*arg2)
              else # negative arg1
                stack.unshift(arg1,arg2,arg3)
              end
            else # arg2 not arg3
              code.unshift(:until0,arg3)
              stack.unshift(arg1,arg2)
            end
          else
            if match3 # arg3 not arg2
              code.unshift(:until0,arg2)
              stack.unshift(arg1,arg3)
            else # neither is list
              code.unshift(:until0,arg2,arg3)
              stack.unshift(arg1)
            end
          end
        else
          stack.unshift(arg1,arg2,arg3)
        end
        stack.unshift(code)
      end
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
            stack[0].unshift(*(deep_copy(arg1)))
          end
        else # for now; this could become a continuation
          stack.insert(1,arg1,arg2,arg3)
        end
      end
      return stack
    end
  end
end