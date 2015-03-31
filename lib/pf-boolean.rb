module PushForth
  class PushForthInterpreter

    ### boolean

    def boolean_arity_2(instruction, stack, &math_proc)
      unless stack.length < 3
          code = stack.shift
        arg1, arg2 = stack.shift(2)
        k1,k2 = [boolean?(arg1),boolean?(arg2)]
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


    def and(stack)
      return boolean_arity_2(:and, stack) do |a,b|
        a && b
      end
    end


    def or(stack)
      return boolean_arity_2(:or, stack) do |a,b|
        a || b
      end
    end


    def not(stack)
      if boolean?(stack[1])
        stack[1] = !stack[1]
      end
      return stack
    end


    def if(stack)
      if stack.length > 2
          code = stack.shift
        arg1, arg2 = stack.shift(2)
        if boolean?(arg1)
          stack.unshift(arg2) if arg1
        else
          code.unshift(:if,arg1)
        end
        stack.unshift(code)
      end
      return stack
    end


    def which(stack)
      if stack.length > 3
          code = stack.shift
        arg1, arg2, arg3 = stack.shift(3)
        if boolean?(arg1)
          stack.unshift(arg1 ? arg2 : arg3) 
        else
          code.unshift(:which,arg1)
          stack.unshift(arg2,arg3)
        end
        stack.unshift(code)
      end
      return stack
    end
  end
end