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
  which = [:randomInstruction,:randomInstruction,:randomInstruction,:randomInstruction,:randomInstruction,:randomInstruction,:randomInteger,:randomFloat,:randomBool].sample
  self.method(which).call()
end

def blockOf5
  5.times.collect {randomToken}
end

def blockOf50
  10.times.collect {blockOf5}
end

def random_tree
  PushForthInterpreter.new ([blockOf50.flatten ] + blockOf50)
end


def build_tree(tokens)
  tree = []
  done = false
  until tokens.empty? || done
    token = tokens.shift
    if token == "("
      meta_token = build_tree(tokens)
      tree << meta_token
    elsif token == ")"
      done = true
    else
      tree << token
    end
  end
  return tree
end


def tree2(points,prob=0.1)
  triggers = []
  script = []
  while points > 0
    if Random.rand() < prob
      # branch
      triggers << 0
      script << "("
    else
      script << randomToken
    end
    points -= 1
    triggers = triggers.map {|t| t += 1}
    if triggers[0] && triggers[0] > 1.0/prob
      script << ")"
      points -= 1
      triggers = triggers.drop(1)
    end
  end
  while triggers[0]
    script << ")"
    points -= 1
    triggers = triggers.drop(1)
  end

  script = build_tree(script)

  return script
end

def first_number(dude)
  dude.stack.detect {|item| item.kind_of?(Numeric)}
end

t = tree2(100)
puts build_tree(t).inspect

dudes = 5000.times.collect do
  x = Random.rand(100)
  y = 9*x*x - 11*x + 1964
  pf = PushForthInterpreter.new([tree2(50,0.1)] + tree2(50), [x])
  puts "#{pf.stack.inspect}"
  pf.run
  puts ">>>   #{pf.stack.inspect}"
  err = first_number(pf) ? (first_number(pf) - y).abs  : nil
  puts "#{err}\n\n"
  STDOUT.flush
  pf
end

puts dudes.collect {|dude| dude.steps}.sort