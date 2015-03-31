require_relative '../lib/push-forth'
include PushForth

dude = [[-1.3125, :not, true, :"\u2260", :>, [-9.5, :<, 275, 205, [:cdr, [:flip!, :leafmap, :until0], :map, :set, :dict, [false], :types, -2.03125], :cdr, :leafmap, 15.15625, :>, -5.4375, 10.40625, :set], :dup, :or, 219, :eval, :enlist, :concat, :until0, :leafmap, -2.65625, [:split, 13.34375, 1.75, :add, :noop, :if]], :args, true, :>, :==, :dict, :gather_same, false, :split, -224, false, :enlist, 244, :"\u2265", false, :==, :flip!, :gather_same, :not, :types, 3.71875, :not, :noop, :divmod, -12.78125, -501, :and, 284, :until0, :<, -5.625, :subtract, -14.65625, -172, :>, :until0, :is_a?, [[-14.21875, :>, 476, :<, :==, :noop, false, false, 13.1875], []]]


# [[4.4375, :divmod, 308, 398, :until0, :noop, :while, :divmod, false, 2.46875, 174, 300, -273, :if, [:which, :get, false, false, :if, [-5.0625, :car, :not, :is_a?], -30, :≥, :set, :which, :which, :swap], false, :swap, -309, true, -22, [:noop, 15.5625, :noop, [true, :gather_same, [:gather_same, :get, :divide]]]], :cdr, :dup, :dup, :cdr, false, -9.65625, false, true, [:leafmap, :not, :map, :>, :is_a?, :if, :split, -8.53125, :==, :divide], :map, :until0, :>, 71, :multiply, [:enlist, :pop, :leafmap, -8.3125, :enlist, :noop, :gather_same, :gather_same, :==, :until0], false, :==, :is_a?, :get, :<, :map, -3.375, -11, :gather_same, 2.25, :divmod, :types, -467]




  x = Random.rand(100)
  y = 9*x*x - 11*x + 1964






pf = PushForthInterpreter.new(dude,[x])

(0..5000).each do |i|
  puts i
  puts pf.stack.flatten.length
  pf.step!
  puts pf.stack.inspect
end