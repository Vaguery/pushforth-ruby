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

  attr_accessor :code,:data


  def initialize(token_array=[])
    @data = token_array
    @code = nil
  end


  def evaluable?(code=@code,data=@data)
    if code.nil?
      result = data[0].kind_of?(Array) &&
               !data[0].empty?
    else
      result = code.kind_of?(Array) && 
               data.kind_of?(Array)
    end
    return result
  end


  def stack
    @code.nil? ? @data : @data.unshift(@code)
  end


  def instruction?(item)
    @@instructions.include?(item)
  end


    # code              data
    # ----              ----
    # nil               nil                          FAIL  type error
    # not list          not list                     FAIL  type error
    # not list          []                           FAIL  type error
    # []                not list                     FAIL  type error
    # nil               [[]]                         HALT  normal
    # nil               [[],1,2,3]                   HALT  normal
    # []                []                           HALT  normal
    # []                [1,2,3]                      HALT  normal
    # [1,2,3]           []                           STEP  no split  
    # [1,2,3]           [1,2,3]                      STEP  no split
    # nil               [[],anything]]               STEP  after split
    # nil               [[anything],anything]]       STEP  after split


  def eval(code,data)
    if evaluable?(code,data)
      inner_code = data.shift # known to be a nonempty list: it's evaluable
      item = inner_code.shift
      if instruction?(item)
        inner_code,data = self.method(item).call(inner_code,data)
      else
        data.unshift(item)
      end
      data.unshift(inner_code)
    end
    return code,data
  end


  def step!
    @code,@data = eval(@code,@data) if self.evaluable?
    self
  end

  ### instructions
  ### arithmetic

  def arithmetic(instruction, code, data, &math_proc)
    unless data.length < 2
      arg1, arg2 = data.shift(2)
      k1,k2 = [arg1.kind_of?(Numeric),arg2.kind_of?(Numeric)]
      if k1 && k2
        data.unshift(math_proc.call(arg1,arg2))
      elsif k1
        code.unshift(instruction,arg2)
        data.unshift(arg1)
      elsif k2
        code.unshift(instruction,arg1)
        data.unshift(arg2)
      else
        data.unshift(arg2,arg1)
      end
    end
    return code,data
  end


  def add(code,data)
    return arithmetic(:add, code, data) do |a,b|
      a+b
    end
  end


  def divide(code,data)
    return arithmetic(:divide, code, data) do |a,b|
      (b.zero? ? Error.new("div0") : a/b)
    end
  end


  def multiply(code,data)
    return arithmetic(:multiply, code, data) do |a,b|
      a*b
    end
  end


  def subtract(code,data)
    return arithmetic(:subtract, code, data) do |a,b|
      a-b
    end
  end


  ### combinators

  def car(code,data)
    if data[0].kind_of?(Array)
      arg = data.shift
      data.unshift(arg[0]) unless arg.empty?
    end
    return code,data
  end


  def cdr(code,data)
    if data[0].kind_of?(Array)
      arg = data.shift
      data.unshift(arg.drop(1)) unless arg.empty?
    end
    return code,data
  end


  def concat(code,data)
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
    return code,data
  end


  def cons(code,data)
    if data.length > 1
      arg1,arg2 = data.shift(2)
      if arg2.kind_of?(Array)
        data.unshift(arg2.unshift(arg1))
      else
        code.unshift(:cons,arg2)
        data.unshift(arg1)
      end
    end
    return code,data
  end


  def dup(code,data)
    data.unshift(data[0]) unless data.empty?
    return code,data
  end


  def enlist(code,data)
    if data[0].kind_of?(Array)
      code += data.shift
    end
    return code,data
  end


  def pop(code,data)
    unless data.length < 1
      discard = data.shift
    end
    return code,data
  end


  def rotate(code,data)
    unless data.length < 3
      a1,a2,a3 = data.shift(3)
      data.unshift(a2,a3,a1)
    end
    return code,data
  end


  def split(code,data)
    unless data.length < 1
      if data[0].kind_of?(Array) && data[0].length > 1 
        arg = data.shift
        data.unshift(arg[0],arg.drop(1))
      end
    end
    return code,data
  end


  def swap(code,data)
    data.unshift(*data.shift(2).reverse) unless data.length < 2
    return code,data
  end


  def unit(code,data)
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
    return code,data
  end

  ### misc

  def noop(code,data)
    return code,data
  end


  def while(code,data)
    if data.length > 2
      arg1,arg2,arg3 = data.shift(3)
      # puts "#{arg1},#{arg2},#{arg3}"
      k1,k2,k3 = [arg1,arg2,arg3].collect {|a| a.kind_of?(Array)}
      if (k1 && k2 && k3) 
        if arg2.empty?
          data.unshift(arg2,arg3)
        else
          data.unshift(arg3)
          code.unshift(:enlist)
          code.unshift([arg1,:while])
          code.unshift(*arg1)
        end
      else # for now; this could become a continuation
        data.unshift(arg1,arg2,arg3)
      end
    end
    return code,data
  end
end