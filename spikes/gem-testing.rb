require 'pushforth'
include PushForth

dude = [[-419, 4.3125..4.937448971311051, :wrapitup, (79/58), -10.71875..27.95256649957986, -373, :types, (1/1), :cons, 463..479, (88/71), 13.53125, (26/5), :args, -438..-346, :==, :is_a?, [:snapshot, :cons, (1/1), -1.53125, :gather_same, :eval, (1/19), true, (17/2), -397], true, 359, true, [-3.1875, :swap, :rotate, false, :enlist, [true, :which, :cdr, false], -112, false, -15.6875..-13.979272221122924, :flip!, 3.625, 9.125]], :add, :not, :leafmap, [false, 12.28125..24.669040752617583, [false, -8.09375, :types, [(16/5), -15.21875, :args], false, -2.375, 11.875], 224, -3.8125, :pop!, -7.1875], -290, :not, :type, (27/29), :or, :again, :until0, :not, :which, :unit, :merge, -15.28125..-3.763113509209015, 11.125, :if, 4.78125..8.949632225180391, :cdr, :types, 12.0625, :gather_same, 379, :≠, (91/11), :≥, :subtract, (19/12), (17/31)]

  x = Random.rand(100)
  y = 9*x*x - 11*x + 1964






pf = PushForthInterpreter.new(dude,[x])

# (0..1000).each do |i|
#   puts i
#   puts pf.stack.flatten.length
#   pf.step!
#   puts pf.stack.inspect
# end

pf.run(step_limit:5000,time_limit:120,size_limit:3000,depth_limit:500,trace:true)
puts pf.stack.inspect
