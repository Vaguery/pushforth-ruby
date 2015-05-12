module PushForth
  class Script < String

    def self.to_program(string)
      result =  eval(string)
      if result.nil?
        return []
      elsif result.kind_of?(Array)
        return result
      else
        return [result]
      end
    end
  
  end
end
