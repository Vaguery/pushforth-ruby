require_relative '../lib/push-forth'
include PushForth

dude = [[5.1875, [-460, 7.25, :is_a?, [6.40625, true, [:which, -50, 510], -2.6875, :swap, :>, :cdr], :eval, :gather_all, :car], :while, :≤, :noop, -22, -381, :or, -1.46875, :≥, :while, :≠, :if, :split, [:args, :cdr, :==, :types, [false, :or, :until0, :which, :<], :gather_same, :not, :split, -13.03125]], :set, false, :unit, :until0, :unit, 6.75, false, 10.0, :divide, :args, 131, :==, :car, 181, :>, -106, :type, :cons, :set, :gather_all, :and, :not, :map, :if, false, false, :or, :gather_all, :add, :cons, :noop, :subtract, :gather_same, :dict, :concat, 9.59375, -3.78125, :split, [true, :or, :set, :until0, 506, true, :==, 314, :≠, :divmod]]




pf = PushForthInterpreter.new(dude)

(0..1000).each do |i|
  puts i
  puts pf.stack.flatten.length
  pf.step!
  puts pf.stack.inspect
end