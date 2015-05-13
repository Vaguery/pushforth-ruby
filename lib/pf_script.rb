module PushForth
  class Script < String

    # assume a script is a comma-delimited list where brackets are legal items
    def self.to_program(string)
      string = balance_brackets(string)

      string = string.gsub(/,\s*\]/,"]")
      string = string.gsub(/\[\s*,/,"[")
      result =  eval("[#{string}]")
      if result.nil?
        return []
      elsif result.kind_of?(Array)
        return result
      else
        return [result]
      end
    end


    def self.balance_brackets(raw_script)
      token_list = raw_script.split(",")
      new_tokens = []
      nesting = 0
      token_list.each do |token|
        token.strip!
        if token == ']'
          if nesting > 0
            nesting -= 1
            new_tokens.push token
          end
        elsif token == '['
          nesting += 1
          new_tokens.push token
        else  
          new_tokens.push token
        end
      end
      new_tokens += ([']'] * nesting)
      return new_tokens.join(",")
    end
  end
end
