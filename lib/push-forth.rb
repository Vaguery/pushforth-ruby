class Error
  attr_reader :string
  def initialize(string)
    @string = string
  end
end


class PushForth
  attr_accessor :stack

  @@instructions = [:dup, :swap, :rotate, :eval, 
    :add, :subtract, :multiply, :divide, 
    :enlist]


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


  def rotate(data,code)
    unless data.length < 3
      a1,a2,a3 = data.shift(3)
      data.unshift(a2,a3,a1)
    end
    return [data,code]
  end


  def enlist(data,code)
    if data[0].kind_of?(Array)
      code += data.shift
    end
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


  def evaluable?(array)
    !array.empty? && array[0].kind_of?(Array)
  end


  def eval(data,code)  ## the core of the language
    if evaluable?(data)
      new_code = data.shift
      if new_code.empty?
      else
        running_item = new_code.shift
        if instruction?(running_item)
          data,new_code = self.method(running_item).call(data,new_code)
          data.unshift(new_code)
        else
          data.unshift(new_code,running_item)
        end
      end
    end
    return data,code
  end


  def step
    @stack,code = eval(@stack,nil) if @stack[0].kind_of?(Array)
    return self
  end
end