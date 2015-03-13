class Error
  attr_reader :string
  def initialize(string)
    @string = string
  end
end


class PushForth
  attr_accessor :stack

  @@instructions = [:eval, 
    :add, :subtract, :multiply, :divide, 
    :enlist, :cons, :pop, :dup, :swap, :rotate, :split, 
    :car, :cdr, :concat, :unit]


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


  def pop(data,code)
    unless data.length < 1
      discard = data.shift
    end
    return [data,code]
  end


  def split(data,code)
    unless data.length < 1
      if data[0].kind_of?(Array) && data[0].length > 1 
        arg = data.shift
        data.unshift(arg[0],arg.drop(1))
      end
    end
    return [data,code]
  end


  def enlist(data,code)
    if data[0].kind_of?(Array)
      code += data.shift
    end
    return [data,code]
  end


  def car(data,code)
    if data[0].kind_of?(Array)
      arg = data.shift
      data.unshift(arg[0]) unless arg.empty?
    end
    return [data,code]
  end


  def cdr(data,code)
    if data[0].kind_of?(Array)
      arg = data.shift
      data.unshift(arg.drop(1)) unless arg.empty?
    end
    return [data,code]
  end


  def unit(data,code)
    if data[0].kind_of?(Array)
      arg = data.shift
      case arg.length
      when 0
        data.unshift([],[])
      when 1
        data.unshift(arg,[])
      else
        data.unshift([arg[0]],arg[1..-1])
      end
    end
    return [data,code]
  end



  def cons(data,code)
    if data.length > 1
      arg1,arg2 = data.shift(2)
      if arg2.kind_of?(Array)
        data.unshift(arg2.unshift(arg1))
      else
        code.unshift(:cons,arg2)
        data.unshift(arg1)
      end
    end
    return [data,code]
  end


  def concat(data,code)
    unless data.length < 2
      arg1, arg2 = data.shift(2)
      k1,k2 = [arg1.kind_of?(Array),arg2.kind_of?(Array)]
      if k1 && k2
        data.unshift(arg1+arg2)
      elsif k1
        code.unshift(:concat,arg2)
        data.unshift(arg1)
      elsif k2
        code.unshift(:concat,arg1)
        data.unshift(arg2)
      else
        data.unshift(arg2,arg1)
      end
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
    result = !array.empty? && array[0].kind_of?(Array) && !array[0].empty?
    return result
  end


  def eval(data,code)  ## the core of the language
    if evaluable?(data)
      new_code = data.shift
      running_item = new_code.shift
      if instruction?(running_item)
        data,new_code = self.method(running_item).call(data,new_code)
        data.unshift(new_code)
      else
        data.unshift(running_item)
        data.unshift(new_code)
      end
    end
    return data,code
  end


  def step
    new_data,new_code = eval(@stack,nil) if evaluable?(@stack)
    @stack = new_data.unshift(new_code) unless new_code.nil?
    return self
  end
end