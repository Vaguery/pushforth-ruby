require_relative '../lib/push-forth'
include PushForth

dude = [[250, :not, :until0, -0.1875, :add, [6.8125, :cdr, 10.09375, true, :types, :≤, :args, [9.8125, false], :while, :≠, false, true, [:cdr, true, [], :rotate, 5.28125, false, :>, :dict, :which, 411], :leafmap, :>, :dict], :types, :divmod, :noop, [:pop, :type, :add, :enlist, :and, 112, true, :or]], [:cons, 14.46875, :enlist, 14.96875, :get, true, false, :not, :==, :unit], :is_a?, 15.875, :dup, -10.78125, :≥, -5.40625, :map, :eval, false, -305, :divide, :flip!, :gather_all, true, [:multiply, :gather_same, :≥, :cdr, :is_a?, [:gather_all, [:unit, 13.0], -209, :pop, -12.6875, :==, :type, :map], 189, :swap], :set, :<]



  x = Random.rand(100)
  y = 9*x*x - 11*x + 1964






pf = PushForthInterpreter.new(dude,[x])

(0..1000).each do |i|
  puts i
  puts pf.stack.flatten.length
  pf.step!
  puts pf.stack.inspect
end