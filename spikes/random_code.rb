require_relative '../lib/pushforth'
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

def randomRational
  Rational(Random.rand(100),Random.rand(100)+1)
end

def randomBracket
  [']','['].sample
end

def randomRange
  if Random.rand() < 0.5
    first = randomInteger
    last = first + Random.rand(100)
    (first..last)
  else
    first = randomFloat
    last = first + Random.rand() * Random.rand(100)
    (first..last)
  end
end

def randomToken
  which = [:randomBracket,:randomBracket,:randomInstruction,:randomInstruction,:randomInstruction,:randomInstruction,:randomInteger,:randomFloat,:randomBool, :randomRational, :randomRange].sample
  self.method(which).call()
end


def first_number(dude)
  dude.stack.detect {|item| item.kind_of?(Numeric)}
end

def linear_tokens(length)
  length.times.collect {randomToken}
end

def light_handed_join(array_of_tokens)
  (array_of_tokens.collect {|token| token.is_a?(Symbol) ? token.inspect : token}).join(",")
end

def random_program(length)
  tokens = linear_tokens(length)
  return [Script.to_program(light_handed_join(tokens))]
end

# puts random_program(20).inspect

# pf = PushForthInterpreter.new([tree2(50,0.1)] + tree2(50))
# puts pf.stack.inspect
# puts id_tree(pf.stack).inspect

File.open("discard.csv","w") do |file|
  dudes = (0..10000).collect do |i|
    x = Random.rand(100)
    pf = PushForthInterpreter.new(random_program(100), [x])
    puts i
    file.puts i
    file.puts "#{pf.stack.inspect}"
    file.puts ">>>  args: #{[x]}"
    begin
      pf.run(step_limit:5000,time_limit:120,size_limit:3000,depth_limit:500)
      file.puts ">>>  #{pf.stack.inspect}"
    rescue SystemStackError => boom
      puts boom.message
      file.puts "**** #{boom.message} at interpreter step #{pf.steps}"
      file.puts "**** state at interpreter step #{pf.steps}:"
      file.puts pf.stack.inspect
    rescue StandardError => bang 
      puts "**** #{bang.message} at interpreter step #{pf.steps}"
      file.puts "**** #{bang.message} at interpreter step #{pf.steps}"
      file.puts "**** state at interpreter step #{pf.steps}:"
      file.puts pf.stack.inspect
    end
    pf
  end

  puts "\nsteps run:"
  puts dudes.collect {|dude| dude.steps}.sort
end
