class PushForth
  attr_accessor :stack

  @@instructions = [:dup, :swap, :eval]


  def initialize(items_array=[[]])
    @stack = items_array
  end


  def instruction?(thing)
    return @@instructions.include?(thing) ? true : false
  end


  def dup(context)
    context.unshift(context[0]) unless context.empty?
    return context
  end

  
  def swap(context)
    context.unshift(*context.shift(2).reverse) unless context.length < 2
    return context
  end


  def step
    @stack = eval(@stack) if @stack[0].kind_of?(Array)
    return self
  end


  def eval(context)
    arg = context.shift
    unless arg.empty?
      item = arg.shift
      case
      when instruction?(item)
        context = self.method(item).call(context)
      else
        context.unshift(arg,item)
      end
    end
    return context
  end
end