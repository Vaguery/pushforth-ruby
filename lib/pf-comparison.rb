module PushForth
  class PushForthInterpreter

    ### comparison 

    def >(stack)
      return arithmetic(:>, stack) do |a,b|
        if a.kind_of?(Complex) || b.kind_of?(Complex)
          Error.new("compared Complex values")
        else
           a > b
        end
      end
    end

    def <(stack)
      return arithmetic(:<, stack) do |a,b|
        if a.kind_of?(Complex) || b.kind_of?(Complex)
          Error.new("compared Complex values")
        else
           a > b
        end
      end
    end

    def ≥(stack)
      return arithmetic(:≥, stack) do |a,b|
        if a.kind_of?(Complex) || b.kind_of?(Complex)
          Error.new("compared Complex values")
        else
           a >= b
        end
      end
    end

    def ≤(stack)
      return arithmetic(:≤, stack) do |a,b|
        if a.kind_of?(Complex) || b.kind_of?(Complex)
          Error.new("compared Complex values")
        else
           a <= b
        end
      end
    end

    def ==(stack)
      return arithmetic(:==, stack) do |a,b|
        a == b
      end
    end

    def ≠(stack)
      return arithmetic(:≠, stack) do |a,b|
        a != b
      end
    end
  end
end