module PushForth
  class PushForthInterpreter
    ### combinators

    def car(stack)
      if stack.length > 1
        code,arg = stack.shift(2)
        if list?(arg)
          stack.unshift(arg[0]) unless arg.empty? 
        else
          code.unshift(:car,arg)
        end
        stack.unshift(code)
      end
      return stack
    end


    def cdr(stack)
      if stack.length > 1
        code,arg = stack.shift(2)
        if list?(arg)
          stack.unshift(arg.drop(1)) unless arg.empty? 
        else
          code.unshift(:cdr,arg)
        end
        stack.unshift(code)
      end
      return stack
    end


    def concat(stack)
      if stack.length > 2
        code,arg1,arg2 = stack.shift(3)
        type1 = list?(arg1)
        type2 = list?(arg2)
        if type1 && type2
          stack.unshift(arg1+arg2)
        elsif type1
          code.unshift(:concat,arg2)
          stack.unshift(arg1)
        elsif type2
          code.unshift(:concat,arg1)
          stack.unshift(arg2)
        else
          code.unshift(:concat,arg1,arg2)
        end
        stack.unshift(code)
      end
      return stack
    end


    def cons(stack)
      if stack.length > 2
        code = stack.shift
        arg1,arg2 = stack.shift(2)
        if list?(arg2)
          arg2.unshift(arg1)
          stack.unshift(arg2)
        else
          code.unshift(:cons,arg2)
          stack.unshift(arg1)
        end
        stack.unshift(code)
      end
      return stack
    end


    def dup(stack)
      stack.insert(1,deep_copy(stack[1])) unless stack.length < 2
      return stack
    end


    def enlist(stack)
      if stack.length > 1
        code,arg = stack.shift(2)
        list?(arg) ? code.push(*arg) : code.unshift(:enlist,arg)
        stack.unshift(code)
      end
      return stack
    end


    def flip!(stack)
      code = stack.shift
      stack = [stack] + code 
      return stack
    end


    def pop!(stack)
      if stack.length > 2
        stack.delete_at(1)
      end
      return stack
    end


    def reverse(stack)
      if stack.length > 1
        code = stack.shift
        arg = stack.shift
        list?(arg) ? stack.unshift(arg.reverse) : code.unshift(:reverse,arg)
        stack.unshift(code)
      end
      return stack
    end


    def reverse!(stack)
      return stack.reverse
    end


    def rotate(stack)    
      stack[1],stack[2],stack[3] = stack[2],stack[3],stack[1] if stack.length > 3
      return stack
    end


    def pop(stack)
      if stack.length > 1
        code = stack.shift
        arg = stack.shift
        if list?(arg)
          if arg.empty?
            stack.unshift(arg)
          else
            popped = arg.shift
            stack.unshift(popped,arg)
          end
        else
          code.unshift(:pop,arg)
        end
        stack.unshift(code)
      end
      return stack
    end


    def swap(stack)
      stack[1],stack[2] = stack[2],stack[1] unless stack.length < 3
      return stack
    end


    def unit(stack)
      if stack.length > 1
        code,arg = stack.shift(2)
        if list?(arg)
          if !arg.empty?
            popped = arg.shift
            stack.unshift([popped],arg)
          else
            stack.unshift([],[])
          end
        else
          code.unshift(:unit,arg)
        end
        stack.unshift(code)
      end
      return stack
    end


    def append_to_leaves(tree_array,suffix_array)
      result = []
      tree_array.each do |item|
        if item.kind_of?(Array)
          result << append_to_leaves(deep_copy(item),deep_copy(suffix_array))
        else
          result += ([deep_copy(item)] + deep_copy(suffix_array))
        end
      end
      return result
    end


    def leafmap(stack)
      if stack.length > 2
        code = stack.shift
        arg1,arg2 = stack.shift(2)
        if list?(arg1) && list?(arg2)
          mapped = append_to_leaves(deep_copy(arg1),deep_copy(arg2))
        elsif list?(arg2)
          mapped = deep_copy(arg2).unshift(deep_copy(arg1))
        else
          mapped = append_to_leaves([deep_copy(arg1)],[deep_copy(arg2)])
        end
        code.unshift(*mapped)
        stack.unshift(code)
      end
      return stack
    end


    def map(stack)
      if stack.length > 2
        code = stack.shift
        arg1,arg2 = stack.shift(2)
        if list?(arg1) && list?(arg2)
          mapped = arg1.collect do |i|
            [i] + deep_copy(arg2)
          end
          mapped = mapped.flatten(1)
        elsif list?(arg2)
          mapped = arg2.unshift(arg1)
        else
          mapped = [arg1,arg2]
        end
        code.unshift(*mapped)
        stack.unshift(code)
      end
      return stack
    end


    def until0(stack)
      if stack.length > 3
        code = stack.shift
        arg1,arg2,arg3 = stack.shift(3)
        match1 = arg1.kind_of?(Integer) && arg1 >= 0
        match2 = list?(arg2)
        match3 = list?(arg3)
        if match1
          if match2
            if match3
              if arg1 > 0
                code.unshift(*deep_copy(arg3),arg3,arg2,arg1-1,:until0)
              else
                code.unshift(*arg2)
              end
            else
              code.unshift(:until0,arg3)
              stack.unshift(arg1,arg2)
            end
          else
            code.unshift(:until0,arg2)
            stack.unshift(arg1,arg3)
          end
        else
          code.unshift(:until0,arg1)
          stack.unshift(arg2,arg3)
        end
        stack.unshift(code)
      end
      return stack
    end


    def while(stack)
      if stack.length > 3
        arg1 = stack.delete_at(1)
        arg2 = stack.delete_at(1)
        arg3 = stack.delete_at(1)
        k1,k2,k3 = [arg1,arg2,arg3].collect {|a| a.kind_of?(Array)}
        if (k1 && k2 && k3) 
          if arg2.empty?
            stack.insert(1,arg2,arg3)
          else
            stack.insert(1,arg3)
            stack[0].unshift(:enlist)
            stack[0].unshift([arg1,:while])
            stack[0].unshift(*(deep_copy(arg1)))
          end
        else # for now; this could become a continuation
          stack.insert(1,arg1,arg2,arg3)
        end
      end
      return stack
    end
  end
end