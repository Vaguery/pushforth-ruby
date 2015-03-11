class PushForth
  attr_accessor :stack

  @@instructions = [:dup, :swap]


  def initialize(items_array=[[]])
    @stack = items_array
  end


  def instruction?(thing)
    return @@instructions.include?(thing) ? true : false
  end


  def dup
    @stack.unshift(@stack[0]) unless @stack.empty?
    return self
  end
  
  def swap
    @stack.unshift(*@stack.shift(2).reverse) unless @stack.length < 2
    return self
  end

  def eval
    return self unless @stack[0].kind_of?(Array)
    arg = @stack.shift
    unless arg.empty?
      item = arg.shift
      case
      when instruction?(item)
        self.method(item).call
      else
        @stack.unshift(arg,item)
      end
    end
    return self
  end
  
end