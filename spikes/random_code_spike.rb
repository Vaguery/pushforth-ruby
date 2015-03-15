require_relative '../lib/push-forth'
include PushForth


def randomInstruction
  PushForthInterpreter.instructions.sample
end

def randomInteger
  Random.rand(1024)-512
end

def randomFloat
  randomInteger/32.0
end

def randomBool
  [true, false].sample
end

def randomToken
  which = [:randomInstruction,:randomInstruction,:randomInstruction,:randomInteger,:randomFloat,:randomBool].sample
  self.method(which).call()
end

def blockOf5
  5.times.collect {randomToken}
end

def blockOf50
  10.times.collect {blockOf5}
end

def rando
  PushForthInterpreter.new ([blockOf50.flatten ] + blockOf50)
end


## this might easily fall into an infinite loop...
counts = 1000.times.collect do
  runner = rando
  @counter = 0
  until runner.halted? do
    runner.step!
    @counter += 1
  end
  # puts "#{runner.stack.inspect}"
  @counter
end

puts counts.sort