module PushForth
  class PushForthInterpreter
    ### combinators

    def car(stack)
      if stack[1].kind_of?(Array)
        arg = stack.delete_at(1)
        stack.insert(1,arg[0]) unless arg.empty?
      end
      return stack
    end


    def cdr(stack)
      if stack[1].kind_of?(Array)
        arg = stack.delete_at(1)
        stack.insert(1,arg.drop(1)) unless arg.empty?
      end
      return stack
    end


    def concat(stack)
      if stack.length > 2
        arg1 = stack.delete_at(1)
        arg2 = stack.delete_at(1)
        k1,k2 = [arg1.kind_of?(Array),arg2.kind_of?(Array)]
        if k1 && k2
          stack.insert(1,arg1+arg2)
        elsif k1
          stack[0].unshift(:concat,arg2)
          stack.insert(1,arg1)
        elsif k2
          stack[0].unshift(:concat,arg1)
          stack.insert(1,arg2)
        else
          stack.insert(1,arg2,arg1)
        end
      end
      return stack
    end


    def cons(stack)
      if stack.length > 2
        arg1 = stack.delete_at(1)
        arg2 = stack.delete_at(1)
        if arg2.kind_of?(Array)
          stack.insert(1, arg2.unshift(deep_copy(arg1)) )
        else
          stack[0].unshift(:cons,arg2)
          stack.insert(1,arg1)
        end
      end
      return stack
    end


    def dup(stack)
      stack.insert(1,deep_copy(stack[1])) unless stack.length < 2
      return stack
    end


    def enlist(stack)
      if stack[1].kind_of?(Array)
        stack[0] += stack.delete_at(1)
      end
      return stack
    end


    def flip!(stack)
      old_code = stack.shift
      stack = [stack] + old_code 
      return stack
    end


    def pop(stack)
      if stack.length > 2
        stack.delete_at(1)
      end
      return stack
    end


    def reverse(stack)
      if stack.length > 1
        code = stack.shift
        stack[0].reverse! if list?(stack[0])
        stack.unshift(code)
      end
      return stack
    end


    def rotate(stack)    
      stack[1],stack[2],stack[3] = stack[2],stack[3],stack[1] if stack.length > 3
      return stack
    end


    def split(stack)
      if stack.length > 1
        if stack[1].kind_of?(Array) && stack[1].length > 1 
          arg = stack.delete_at(1)
          out1 = arg[0]
          out2 = arg.drop(1)
          stack.insert(1,out1,out2)
        end
      end
      return stack
    end


    def swap(stack)
      stack[1],stack[2] = stack[2],stack[1] unless stack.length < 3
      return stack
    end


    def unit(stack)
      if stack[1].kind_of?(Array)
        arg = stack.delete_at(1)
        case arg.length
        when 0
          stack.insert(1,[],[])
        when 1
          stack.insert(1,arg,[])
        else
          stack.insert(1,[arg[0]],arg[1..-1])
        end
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
        if arg1.kind_of?(Array) && arg2.kind_of?(Array)
          mapped = append_to_leaves(deep_copy(arg1),deep_copy(arg2))
        elsif arg2.kind_of?(Array)
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
        if arg1.kind_of?(Array) && arg2.kind_of?(Array)
          mapped = arg1.collect do |i|
            [i] + deep_copy(arg2)
          end
          mapped = mapped.flatten(1)
        elsif arg2.kind_of?(Array)
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
        match2 = arg2.kind_of?(Array)
        match3 = arg3.kind_of?(Array)
        if match1
          if match2
            if match3
              if arg1 > 0
                code.unshift(*deep_copy(arg3),arg3,arg2,arg1-1,:until0)
              elsif arg1 == 0
                code.unshift(*arg2)
              else # negative arg1
                stack.unshift(arg1,arg2,arg3)
              end
            else # arg2 not arg3
              code.unshift(:until0,arg3)
              stack.unshift(arg1,arg2)
            end
          else
            if match3 # arg3 not arg2
              code.unshift(:until0,arg2)
              stack.unshift(arg1,arg3)
            else # neither is list
              code.unshift(:until0,arg2,arg3)
              stack.unshift(arg1)
            end
          end
        else
          stack.unshift(arg1,arg2,arg3)
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