module PushForth
  class PushForthInterpreter   

    ### arithmetic

    def arithmetic(instruction, stack, &math_proc)
      unless stack.length < 3
          code = stack.shift
        arg1, arg2 = stack.shift(2)
        k1,k2 = [arg1.kind_of?(Numeric),arg2.kind_of?(Numeric)]
        if k1 && k2
          stack.unshift(math_proc.call(arg1,arg2))
        elsif k1
          code.unshift(instruction,arg2)
          stack.unshift(arg1)
        elsif k2
          code.unshift(instruction,arg1)
          stack.unshift(arg2)
        else
          stack.unshift(arg2,arg1)
        end
        stack.unshift(code)
      end
      return stack
    end


    def add(stack)
      return arithmetic(:add, stack) do |a,b|
        if (a+b).kind_of?(Bignum)
          Error.new("arithmetic overflow")
        else
          a+b
        end
      end
    end


    def divide(stack)
      return arithmetic(:divide, stack) do |a,b|
        (b.zero? ? Error.new("div0") : a/b)
      end
    end


    def divmod(stack)
      return arithmetic(:divmod, stack) do |a,b|
        case 
        when b.kind_of?(Complex)
          Error.new("divmod type error")
        when b.zero?
          Error.new("div0")
        else
          a.divmod(b)
        end
      end
    end


    def multiply(stack)
      return arithmetic(:multiply, stack) do |a,b|
        if (a*b).kind_of?(Bignum)
          Error.new("arithmetic overflow")
        else
          a*b
        end
      end
    end


    def subtract(stack)
      return arithmetic(:subtract, stack) do |a,b|
        if (a-b).kind_of?(Bignum)
          Error.new("arithmetic overflow")
        else
          a-b
        end
      end
    end
  end
end