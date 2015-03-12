class PushForth
  attr_accessor :stack

  @@instructions = [:dup, :swap, :eval, :add]


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


  def add(context)
    return context unless context.length > 1
    arg1, arg2 = context.shift(2)
    k1,k2 = [arg1.kind_of?(Numeric),arg2.kind_of?(Numeric)]
    if k1 && k2
      context.unshift(arg1+arg2)
    elsif k1
    elsif k2
    else
      context.unshift(arg2,arg1)
    end
    return context
  end


  def eval(context)
    if context[0].kind_of?(Array)
      arg = context.shift
      unless arg.empty? 
        item = arg.shift
        case
        when instruction?(item)
          context = self.method(item).call(context)
          context.unshift(arg)
        else
          context.unshift(arg,item)
        end
      end
    end
    return context
  end


  def step
    @stack = eval(@stack) if @stack[0].kind_of?(Array)
    return self
  end
end