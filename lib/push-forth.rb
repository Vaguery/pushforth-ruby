class Error
  attr_reader :string
  def initialize(string)
    @string = string
  end
end


class PushForth
  attr_accessor :stack

  @@instructions = [:dup, :swap, :eval, 
    :add, :subtract, :multiply, :divide]


  def initialize(items_array=[[]])
    @stack = items_array
  end


  def instruction?(thing)
    return @@instructions.include?(thing) ? true : false
  end


  def dup(data,code)
    data.unshift(data[0]) unless data.empty?
    return [data,code]
  end

  
  def swap(data,code)
    data.unshift(*data.shift(2).reverse) unless data.length < 2
    return [data,code]
  end


  def add(data,code)
    unless data.length < 2
      arg1, arg2 = data.shift(2)
      k1,k2 = [arg1.kind_of?(Numeric),arg2.kind_of?(Numeric)]
      if k1 && k2
        data.unshift(arg1+arg2)
      elsif k1
        code.unshift(:add,arg2)
        data.unshift(arg1)
      elsif k2
        code.unshift(:add,arg1)
        data.unshift(arg2)
      else
        data.unshift(arg2,arg1)
      end
    end
    return [data,code]
  end


  def subtract(data,code)
    unless data.length < 2
      arg1, arg2 = data.shift(2)
      k1,k2 = [arg1.kind_of?(Numeric),arg2.kind_of?(Numeric)]
      if k1 && k2
        data.unshift(arg1-arg2)
      elsif k1
        code.unshift(:subtract,arg2)
        data.unshift(arg1)
      elsif k2
        code.unshift(:subtract,arg1)
        data.unshift(arg2)
      else
        data.unshift(arg2,arg1)
      end
    end
    return [data,code]
  end


  def multiply(data,code)
    unless data.length < 2
      arg1, arg2 = data.shift(2)
      k1,k2 = [arg1.kind_of?(Numeric),arg2.kind_of?(Numeric)]
      if k1 && k2
        data.unshift(arg1*arg2)
      elsif k1
        code.unshift(:multiply,arg2)
        data.unshift(arg1)
      elsif k2
        code.unshift(:multiply,arg1)
        data.unshift(arg2)
      else
        data.unshift(arg2,arg1)
      end
    end
    return [data,code]
  end


  def divide(data,code)
    unless data.length < 2
      arg1, arg2 = data.shift(2)
      k1,k2 = [arg1.kind_of?(Numeric),arg2.kind_of?(Numeric)]
      if k1 && k2
        result = (arg2 == 0 ? Error.new("div0") : arg1/arg2)
        data.unshift(result)
      elsif k1
        code.unshift(:divide,arg2)
        data.unshift(arg1)
      elsif k2
        code.unshift(:divide,arg1)
        data.unshift(arg2)
      else
        data.unshift(arg2,arg1)
      end
    end
    return [data,code]
  end



  def eval(data,code)
    if data[0].kind_of?(Array)
      to_eval = data.shift
      if !to_eval.empty? 
        eval_item = to_eval.shift
        if instruction?(eval_item)
          data,code = self.method(eval_item).call(data,to_eval)
          data.unshift(to_eval)
        else
          data.unshift(to_eval,eval_item)
        end
      end
    end
    return data,code
  end


  def step
    @stack,discard = eval(@stack,nil) if @stack[0].kind_of?(Array)
    return self
  end
end