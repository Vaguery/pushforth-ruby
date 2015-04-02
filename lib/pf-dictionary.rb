module PushForth
  class PushForthInterpreter

    ### dictionary instructions
    
    def get(stack)
      if stack.length > 2
        code = stack.shift
        arg1,arg2 = stack.shift(2)
        if dictionary?(arg1)
          stack.unshift(arg1.get(arg2),arg1)
        else
          code.unshift(:get,arg1)
          stack.unshift(arg2)
        end
        stack.unshift(code)
      end
      return stack
    end


    def set(stack)
      if stack.length > 3
        code = stack.shift
        arg1,arg2,arg3 = stack.shift(3)
        if dictionary?(arg1)
          arg1.set(arg2,arg3)
          stack.unshift(arg1)
        else
          code.unshift(:set,arg1)
          stack.unshift(arg2,arg3)
        end
        stack.unshift(code)
      end
      return stack
    end


    def dict(stack)
      return stack.insert(1,PushForth::Dictionary.new)
    end


    def merge(stack)
      if stack.length > 2
        code = stack.shift
        arg1,arg2 = stack.shift(2)
        if dictionary?(arg1) && dictionary?(arg2)
          stack.unshift(Dictionary.new(arg1.contents.merge(arg2.contents)))
        else
        end
        stack.unshift(code)
      end
      return stack
    end
  end
end