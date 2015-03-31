module PushForth
  class PushForthInterpreter

    @@types = [:BooleanType, :ComplexType, :DictionaryType, :ErrorType, :FloatType, :InstructionType, :IntegerType, :ListType, :NumberType, :RationalType, :TypeType, :UnknownType]

    @@type_tree = {:BooleanType => [:BooleanType],
                   :ComplexType => [:ComplexType,:NumberType],
                   :DictionaryType => [:DictionaryType],
                   :ErrorType => [:ErrorType],
                   :FloatType => [:FloatType,:NumberType],
                   :InstructionType => [:InstructionType],
                   :IntegerType => [:IntegerType,:NumberType],
                   :ListType => [:ListType],
                   :NumberType => [:NumberType],
                   :RationalType => [:RationalType,:NumberType],
                   :TypeType => [:TypeType],
                   :UnknownType => [:UnknownType]
                 }

    ## Doesn't include Symbol, since that's trickier
    @@classes_to_types = {Array => :ListType, Complex => :ComplexType, PushForth::Dictionary => :DictionaryType, PushForth::Error => :ErrorType, FalseClass => :BooleanType, Fixnum => :IntegerType, Float => :FloatType, Rational => :RationalType, TrueClass => :BooleanType}

    ### type instructions and helpers

    def recognized_ruby?(item)
      @@classes_to_types.keys.include? item.class
    end

    def is_a?(stack)
      if stack.length > 2
        code = stack.shift
        arg1,arg2 = stack.shift(2)
        if pushforth_type(arg1) == :TypeType
          alternatives = pushforth_types(arg2)
          stack.unshift(alternatives.include?(arg1))
        else
          code.unshift(:is_a?, arg1)
          stack.unshift(arg2)
        end
        stack.unshift(code)
      end
      return stack
    end


    def pushforth_type(item)
      case
      when item.kind_of?(Symbol)
        if @@instructions.include?(item)
          :InstructionType
        elsif @@types.include?(item)
          :TypeType
        else
          :UnknownType
        end
      when recognized_ruby?(item)
        @@classes_to_types[item.class]
      else
        :UnknownType
      end
    end


    def pushforth_types(item)
      @@type_tree[pushforth_type(item)]
    end


    def type(stack)
      if stack.length > 1
        code = stack.shift
        arg = stack.shift
        stack.unshift pushforth_type(arg)
        stack.unshift(code)
      end
      return stack
    end

    def types(stack)
      if stack.length > 1
        code = stack.shift
        arg = stack.shift
        stack.unshift pushforth_types(arg)
        stack.unshift(code)
      end
      return stack
    end

    def gather_all(stack)
      if stack.length > 1
        code = stack.shift
        arg = stack.shift
        if pushforth_type(arg) == :TypeType
          hits,misses = stack.partition {|i| @@type_tree[pushforth_type(i)].include?(arg)}
          stack = misses.unshift(hits)
        else
          stack.unshift(arg)
        end
        stack.unshift(code)
      end
      return stack
    end


    def gather_same(stack)
      if stack.length > 1
        code = stack.shift
        arg = stack.shift
        hits,misses = stack.partition {|i| pushforth_type(i)==pushforth_type(arg)}
        stack = misses.unshift(hits.unshift(arg))
        stack.unshift(code)
      end
      return stack
    end
  end
end