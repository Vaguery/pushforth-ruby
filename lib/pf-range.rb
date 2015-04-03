module PushForth
  class PushForthInterpreter

    ### range instructions

    def cover?(stack)
      if stack.length > 2
        code = stack.shift
        arg1,arg2 = stack.shift(2)
        t1 = arg1.kind_of?(Range)
        t2 = arg2.kind_of?(Numeric) && !arg2.kind_of?(Complex)
        if t1 && t2
          stack.unshift(arg1.cover?(arg2))
        elsif t1
          code.unshift(:cover?,arg2)
          stack.unshift(arg1)
        elsif t2
          code.unshift(:swap,:cover?,arg1)
          stack.unshift(arg2)
        else
          stack.unshift(arg1,arg2)
        end
        stack.unshift(code)
      end
      return stack
    end
  end
end