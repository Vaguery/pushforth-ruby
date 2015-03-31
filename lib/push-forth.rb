module PushForth

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


  class Error
    attr_reader :string
    def initialize(string)
      @string = string
    end
  end


  class PushForthInterpreter
    ## types
    require 'pf-types'

    ## instructions
    require 'pf-arithmetic'
    require 'pf-boolean'
    require 'pf-comparison'
    require 'pf-dictionary'
    require 'pf-functional'
    require 'pf-miscellaneous'

    def self.instructions
      return @@instructions
    end

    @@instructions = [:eval, :noop, :args,
      :add, :subtract, :multiply, :divide, :divmod, 
      :enlist, :cons, :pop, :dup, :swap, :rotate, :split, :car, :cdr, :concat, :unit, :flip!, :reverse, :map, :while, :until0, :leafmap,
      :and, :or, :not, :if, :which,
      :set, :get, :dict,
      :>, :<, :≥, :≤, :==, :≠,
      :type, :types, :is_a?, :gather_all, :gather_same]


    attr_accessor :stack,:steps,:arg_list

    def initialize(token_array=[],args=[])
      @stack = token_array
      @steps = 0
      @arg_list = args
    end


    def get_args
      @arg_list
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


    def step!
      @steps += 1
      @stack = eval(@stack)
      return self
    end


    def run(max_steps=5000,timeout=120)
      done = false
      start_time = Time.now
      while evaluable?(@stack) && !done
        self.step!
        now = Time.now
        if @steps >= max_steps
          done = true
          @stack.insert(1,Error.new("HALTED: #{@steps} steps reached"))
        end
        if (now - start_time) >= timeout
          done = true
          @stack.insert(1,Error.new("HALTED: #{now-start_time} seconds elapsed"))
        end
      end
      self
    end

    ### utilities

    def boolean?(thing)
      thing == true || thing == false
    end

    def dictionary?(thing)
      thing.kind_of? Dictionary
    end

    def list?(thing)
      thing.kind_of? Array
    end

    ### interpreter-facing instructions

    def eval(stack)
      if evaluable?(stack)
        code = stack[0]
        focus = code.shift
        if focus == :eval
          stack[1] = eval(stack[1]) if evaluable?(stack[1])
        elsif instruction?(focus)
          stack = self.method(focus).call(stack)
        else
          stack.insert(1,focus)
        end
      end
      return stack
    end

    def args(stack)
      code = stack.shift
      stack.unshift(*deep_copy(self.get_args))
      stack.unshift(code)
      return stack
    end

    def noop(stack)
      return stack
    end


  end
end