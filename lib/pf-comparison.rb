module PushForth
  class PushForthInterpreter

    ### comparison 

    def ==(stack)
      if stack.length > 2
        code = stack.shift
        arg1,arg2 = stack.shift(2)
        stack.unshift(arg1==arg2)
        stack.unshift(code)
      end
      return stack
    end

    def ≠(stack)
      if stack.length > 2
        code = stack.shift
        arg1,arg2 = stack.shift(2)
        stack.unshift(arg1!=arg2)
        stack.unshift(code)
      end
      return stack
    end


    def comparable?(thing)
      !thing.kind_of?(Symbol) && !thing.kind_of?(Complex) && thing.class.include?(Comparable) 
    end

    def compare(instruction, stack, &math_proc)
      unless stack.length < 3
        code = stack.shift
        arg1, arg2 = stack.shift(2)
        k1 = pushforth_type(arg1)
        k2 = pushforth_type(arg2)
        compy = comparable?(arg1)
        if compy && k1==k2
          stack.unshift(math_proc.call(arg1,arg2))
        elsif compy
          code.unshift(instruction,arg2)
          stack.unshift(arg1)
        else
          code.unshift(instruction,arg1)
          stack.unshift(arg2)
        end
        stack.unshift(code)
      end
      return stack
    end

    def >(stack)
      return compare(:>, stack) do |a,b|
        a > b
      end
    end

    def <(stack)
      return compare(:<, stack) do |a,b|
        a < b
      end
    end

    def ≥(stack)
      return compare(:≥, stack) do |a,b|
        a >= b
      end
    end

    def ≤(stack)
      return compare(:≤, stack) do |a,b|
        a <= b
      end
    end

  end
end