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
      return contents[key] || nil
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
    require_relative File.dirname(__FILE__) + '/pf-types.rb'

    ## instructions
    require_relative File.dirname(__FILE__) + '/pf-arithmetic.rb'
    require_relative File.dirname(__FILE__) + '/pf-boolean.rb'
    require_relative File.dirname(__FILE__) + '/pf-comparison.rb'
    require_relative File.dirname(__FILE__) + '/pf-dictionary.rb'
    require_relative File.dirname(__FILE__) + '/pf-functional.rb'
    require_relative File.dirname(__FILE__) + '/pf-list.rb'
    require_relative File.dirname(__FILE__) + '/pf-miscellaneous.rb'
    require_relative File.dirname(__FILE__) + '/pf-range.rb'
    require_relative File.dirname(__FILE__) + '/pf-script.rb'


    def self.instructions
      return @@instructions
    end

    @@instructions = [
      :add, :again, :and, :args, :become, :car, :cdr, :concat,
      :cons, :cover?, :depth, :dict, :divide, :divmod, :do_times, :dup,
      :enlist, :eval, :flip!, :gather_all, :gather_same, :get, :henceforth,
      :if, :is_a?, :later, :leafmap, :length, :map, :merge, :multiply, :noop,
      :not, :or, :points, :pop, :pop!, :reverse, :reverse!, :rotate, :set,
      :snapshot, :subtract, :swap, :type, :types, :unit, :until0, :which,
      :while, :wrapitup, :≠, :≤, :≥, :<, :==, :>]


    attr_accessor :stack,:steps,:arg_list
    attr_reader :step_limit,:time_limit,:size_limit, :depth_limit

    def initialize(token_array=[],args=[],limits={})
      @stack = token_array
      @steps = 0
      @arg_list = args

      @step_limit = limits[:step_limit] || 1000
      @size_limit = limits[:size_limit] || 1000
      @time_limit = limits[:time_limit] || 120
      @depth_limit = limits[:depth_limit] || 1000
    end

    def get_args
      @arg_list
    end

    def step!
      @steps += 1
      @stack = eval(@stack)
      return self
    end


    def run(arguments={})
      step_limit  = arguments[:step_limit] || @step_limit
      time_limit  = arguments[:time_limit] || @time_limit
      size_limit  = arguments[:size_limit] || @size_limit
      depth_limit = arguments[:depth_limit] || @depth_limit
      trace = arguments[:trace] || false

      done = false
      start_time = Time.now
      while !done && evaluable?(@stack)
        puts @stack.inspect if trace
        self.step!
        now = Time.now
        if size(@stack) >= size_limit
          done = true
          @stack.insert(1,Error.new("HALTED: #{size@stack} points in state"))
        end
        if @steps >= step_limit
          done = true
          @stack.insert(1,Error.new("HALTED: #{@steps} steps reached"))
        end
        if (now - start_time) >= time_limit
          done = true
          @stack.insert(1,Error.new("HALTED: #{now-start_time} seconds elapsed"))
        end
        if max_depth(@stack) >= depth_limit
          done = true
          @stack.insert(1,Error.new("HALTED: #{max_depth(@stack)} exceeds depth limit"))
        end

      end
      self
    end


    ### utilities

    def size(thing)
      case thing
      when Array
        thing.inject(1) {|sum,pt| sum + size(pt)}
      when Dictionary
        thing.contents.inject(1) {|sum,(key,value)| sum + size(key) + size(value)}
      else
        1
      end
    end

    def max_depth(thing)
      case thing
      when Array
        inner_d = thing.collect {|item| max_depth(item)}
        1 + (inner_d.empty? ? 0 : inner_d.max)
      when Dictionary
        inner_d = thing.contents.collect {|k,v| [max_depth(k),max_depth(v)]}
        1 + (inner_d.empty? ? 0 : inner_d.flatten.max)
      else
        0
      end
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

    def boolean?(thing)
      thing == true || thing == false
    end

    def dictionary?(thing)
      thing.kind_of? Dictionary
    end

    def list?(thing)
      thing.kind_of? Array
    end

    def number?(thing)
      pushforth_types(thing)[-1] == :NumberType
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

    def later(stack)
      stack[0].push(stack[0].shift) unless stack[0].empty?
      return stack
    end

    def henceforth(stack)
      code = stack.shift
      code = code + [:henceforth] + deep_copy(code)
      stack.unshift code
      return stack
    end

    def do_times(stack)
      if stack.length > 2
        code = stack.shift
        arg1,arg2 = stack.shift(2)
        type1 = pushforth_type(arg1) == :IntegerType
        type2 = list?(arg2)
        if type1 && type2
          if arg1 > 0
            code.unshift(*deep_copy(arg2),arg2,arg1-1,:do_times)
          else
            stack.unshift(arg2)
          end
        elsif type1
          code.unshift(:do_times,arg2)
          stack.unshift(arg1)
        else type2
          code.unshift(:swap,:do_times,arg1)
          stack.unshift(arg2)
        end
        stack.unshift(code)
      end
      return(stack)
    end

    def snapshot(stack)
      stack.insert(1,deep_copy(stack))
      return stack
    end

    def again(stack)
      code = stack.shift
      code += deep_copy(stack)
      stack.unshift(code)
      return stack
    end

    def wrapitup(stack)
      loopers = [:henceforth, :do_times, :while]
      code = stack.shift
      code = code.delete_if {|item| loopers.include?(item)}
      stack.unshift(code)
      return stack
    end

  end
end