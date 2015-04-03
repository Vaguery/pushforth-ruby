module PushForth
  class PushForthInterpreter

    @@types = [:BooleanType, :ComplexType, :DictionaryType, :ErrorType, :FloatType, :InstructionType, :IntegerType, :ListType, :NumberType, :RangeType, 
      :RationalType, :TypeType, :UnknownType]

    @@type_tree = {:BooleanType => [:BooleanType],
                   :ComplexType => [:ComplexType,:NumberType],
                   :DictionaryType => [:DictionaryType],
                   :ErrorType => [:ErrorType],
                   :FloatType => [:FloatType,:NumberType],
                   :InstructionType => [:InstructionType],
                   :IntegerType => [:IntegerType,:NumberType],
                   :ListType => [:ListType],
                   :NumberType => [:NumberType],
                   :RangeType => [:RangeType],
                   :RationalType => [:RationalType,:NumberType],
                   :TypeType => [:TypeType],
                   :UnknownType => [:UnknownType]
                 }

    ## Doesn't include Symbol, since that's trickier
    @@classes_to_types = {
      Array => :ListType, 
      Bignum => :IntegerType, 
      Complex => :ComplexType, 
      PushForth::Dictionary => :DictionaryType, 
      PushForth::Error => :ErrorType, 
      FalseClass => :BooleanType, 
      Fixnum => :IntegerType, 
      Float => :FloatType, 
      Range => :RangeType,
      Rational => :RationalType, 
      TrueClass => :BooleanType}

    @@convertible_types = [:BooleanType, :ComplexType, 
      :DictionaryType, :FloatType, :IntegerType, :ListType, :RangeType, :RationalType]


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


    def convertible?(thing)
      @@convertible_types.include?(pushforth_type(thing))
    end

    @@type_conversions = {
      [:BooleanType,:ComplexType] => Proc.new {|arg| arg ? Complex(1,1) : Complex(-1,-1) },
      [:BooleanType,:DictionaryType] => Proc.new {|arg| Dictionary.new({arg => arg}) },
      [:BooleanType,:FloatType] => Proc.new {|arg| arg ? 1.0 : -1.0 },
      [:BooleanType,:IntegerType] => Proc.new {|arg| arg ? 1 : -1 },
      [:BooleanType,:ListType] => Proc.new {|arg| arg ? [true] : [false] },
      [:BooleanType,:RationalType] => Proc.new {|arg| arg ? Rational("1/1") : Rational("-1/1") },
      [:ComplexType,:BooleanType] => Proc.new {|arg| arg.real > 0 ? true : false },
      [:ComplexType,:DictionaryType] => Proc.new {|arg| Dictionary.new({arg => arg}) },
      [:ComplexType,:FloatType] => Proc.new {|arg| [arg.real.to_f,arg.imag.to_f] },
      [:ComplexType,:IntegerType] => Proc.new {|arg| [arg.real.to_i,arg.imag.to_i] },
      [:ComplexType,:ListType] => Proc.new {|arg| [arg] },
      [:ComplexType,:RationalType] => Proc.new {|arg| [arg.real.to_r,arg.imag.to_r] },
      [:DictionaryType,:ListType] => Proc.new {|arg| arg.contents.collect {|k,v| [k,v]}.flatten(1) },
      [:FloatType,:BooleanType] => Proc.new {|arg| arg > 0.0 },
      [:FloatType,:ComplexType] => Proc.new {|arg| Complex(arg,0.0) },
      [:FloatType,:DictionaryType] => Proc.new {|arg| Dictionary.new({arg => arg}) },
      [:FloatType,:IntegerType] => Proc.new {|arg| arg.to_i },
      [:FloatType,:ListType] => Proc.new {|arg| [arg] },
      [:FloatType,:RationalType] => Proc.new {|arg| arg.to_r },
      [:IntegerType,:BooleanType] => Proc.new {|arg| arg > 0 },
      [:IntegerType,:ComplexType] => Proc.new {|arg| Complex(arg,0) },
      [:IntegerType,:DictionaryType] => Proc.new {|arg| Dictionary.new({arg => arg}) },
      [:IntegerType,:FloatType] => Proc.new {|arg| arg.to_f },
      [:IntegerType,:ListType] => Proc.new {|arg| [arg] },
      [:IntegerType,:RationalType] => Proc.new {|arg| arg.to_r },
      [:ListType,:DictionaryType] => Proc.new do |arg| 
        arg.length.even?  ? Dictionary.new(Hash[*arg]) : Dictionary.new(Hash[*(arg.take(arg.length-1))])
      end,
      [:RationalType,:BooleanType] => Proc.new {|arg| arg > 0 },
      [:RationalType,:ComplexType] => Proc.new {|arg| Complex(arg,0) },
      [:RationalType,:DictionaryType] => Proc.new {|arg| Dictionary.new({arg => arg}) },
      [:RationalType,:FloatType] => Proc.new {|arg| arg.to_f },
      [:RationalType,:IntegerType] => Proc.new {|arg| arg.to_i },
      [:RationalType,:ListType] => Proc.new {|arg| [arg] }

    }


    def become(stack)
      if stack.length > 2
        code = stack.shift
        arg1,arg2 = stack.shift(2)
        old_type = pushforth_type(arg1)
        if convertible?(arg1)
          if pushforth_type(arg2) == :TypeType
            new_type = arg2
            if old_type == new_type
              stack.unshift(arg1)
            else
              proc = @@type_conversions[ [old_type,new_type] ]
              stack.unshift(proc.nil? ?
                Error.new("Can't convert #{old_type} to #{new_type}") :
                proc.call(arg1))
            end
          else
            stack.unshift(arg1)
            code.unshift(:become,arg2)
          end
        else
          stack.unshift(arg1,arg2)
        end
        stack.unshift(code)
      end
      return stack
    end

  end
end