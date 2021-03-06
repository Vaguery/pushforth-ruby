module PushForth
  class PushForthInterpreter

    ### List & Collection instructions

    def length(stack)
      if stack.length > 1
        code = stack.shift
        arg = stack.shift
        if list?(arg)
          stack.unshift(arg.length)
        elsif dictionary?(arg)
          stack.unshift(arg.contents.keys.length)
        else
          code.unshift(:length,arg)
        end
        stack.unshift(code)
      end
      return stack
    end


    def depth(stack)
      if stack.length > 1
        code = stack.shift
        arg = stack.shift
        stack.unshift(max_depth(arg))
        stack.unshift(code)
      end
      return stack
    end


    def points(stack)
      if stack.length > 1
        code = stack.shift
        arg = stack.shift
        stack.unshift(size(arg))
        stack.unshift(code)
      end
      return stack
    end

  end
end