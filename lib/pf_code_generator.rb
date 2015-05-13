module PushForth
  class CodeGenerator
    def randomInstruction
      PushForthInterpreter.instructions.sample.inspect
    end

    def randomInteger(scale=1024)
      (Random.rand(scale)-scale/2).inspect
    end

    def randomFloat
      (randomInteger.to_i/32.0).inspect
    end

    def randomBool
      ([true, false].sample).inspect
    end

    def randomRational(resolution=100)
      (Rational(Random.rand(resolution),Random.rand(resolution)+1)).inspect
    end

    def randomBracket
      [']','['].sample
    end

    def randomRange(scale=100)
      if Random.rand() < 0.5
        first = randomInteger.to_i
        last = first + Random.rand(scale)
        (first..last).inspect
      else
        first = randomFloat.to_f
        last = first + Random.rand() * Random.rand(scale)
        (first..last).inspect
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

    def random_module(length)
      token_list(length).join(",")
    end

    def random_script(code_length,data_length=0)
      code = random_module(code_length)
      data = random_module(data_length)
      return "[,#{code},],#{data}"
    end
  end
end