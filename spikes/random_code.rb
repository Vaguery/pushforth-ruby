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

def randomRational
  (1/Random.rand(1024)).to_r * randomInteger
end

def randomRange
  Random.rand() < 0.5 ? (randomInteger..randomInteger) :  (randomFloat..randomFloat)
end

def randomToken
  which = [:randomInstruction,:randomInstruction,:randomInstruction,:randomInstruction,:randomInteger,:randomFloat,:randomBool, :randomRational, :randomRange].sample
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

def id_tree(stack)
  stack.collect do |item|
    if item.kind_of?(Array)
      [item.object_id,id_tree(item)]
    elsif item.kind_of?(Dictionary)
      [item.object_id, item.contents.collect {|k,v| [id_tree(k),id_tree(v)]} ]
    else
      0
    end
  end.flatten.sort
end

# pf = PushForthInterpreter.new([tree2(50,0.1)] + tree2(50))
# puts pf.stack.inspect
# puts id_tree(pf.stack).inspect

File.open("discard.csv","w") do |file|
  dudes = (0..100).collect do |i|
    x = Random.rand(100)
    pf = PushForthInterpreter.new([tree2(50,0.1)] + tree2(50), [x])
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
    rescue StandardError => bang 
      puts "**** #{bang.message} at interpreter step #{pf.steps}"
      file.puts "**** #{bang.message} at interpreter step #{pf.steps}"
    end
    pf
  end

  puts "\nsteps run:"
  puts dudes.collect {|dude| dude.steps}.sort
end
