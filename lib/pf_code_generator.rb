module PushForth
  class CodeGenerator
    def randomInstruction
      PushForthInterpreter.instructions.sample
    end

    def randomInteger(scale=1024)
      Random.rand(scale)-scale/2
    end

    def randomFloat
      randomInteger/32.0
    end

    def randomBool
      [true, false].sample
    end

    def randomRational(resolution=100)
      Rational(Random.rand(resolution),Random.rand(resolution)+1)
    end

    def randomBracket
      [']','['].sample
    end

    def randomRange(scale=100)
      if Random.rand() < 0.5
        first = randomInteger
        last = first + Random.rand(scale)
        (first..last)
      else
        first = randomFloat
        last = first + Random.rand() * Random.rand(scale)
        (first..last)
      end
    end

    def defaultRandomToken
      which = [:randomBracket,:randomInstruction,:randomInteger,:randomFloat,:randomBool, :randomRational, :randomRange].sample
      self.method(which).call()
    end

    def token_list(length)
      length.times.collect {defaultRandomToken}
    end

    def light_handed_join(array_of_tokens)
      (array_of_tokens.collect {|token| token.is_a?(Symbol) ? token.inspect : token}).join(",")
    end

    def random_program(code_length,data_length=0)
      code_tokens = token_list(code_length)
      data_tokens = token_list(data_length)
      program = [Script.to_program(light_handed_join(code_tokens))]
      program += Script.to_program(light_handed_join(data_tokens))
      return program
    end
  end
end