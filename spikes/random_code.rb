require_relative '../lib/pushforth'
require_relative '../lib/code-generator'
include PushForth

generator = CodeGenerator.new

File.open("discard.csv","w") do |file|
  dudes = (0..100).collect do |i|
    x = Random.rand(100)
    pf = PushForthInterpreter.new(generator.random_program(99,1), [x])
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
