require_relative '../lib/push-forth'
include PushForth

dude = [[:<, :get, :rotate, :and, 138, :dict, :unit, true, -14.0625, -362, -65, -1.0, :type, -3.4375, :type, :concat, :until0, true, true, :map, :divmod, :multiply, :again, :split, true, true, false, -225, :≠, :snapshot, [326, :wrapitup, :rotate, false, :snapshot, :henceforth, false, -41, :args, :<], -147, [7.6875, :later, [-309, :again, :concat]]], :cons, true, [:gather_all, 114, :type, -496, :is_a?, 5.78125, :==, -12.5625, :not, :get], true, :wrapitup, true, :snapshot, false, :rotate, :swap, -10.1875, :snapshot, -7.875, [:set, 15.71875, :cdr, :is_a?, :flip!, -0.40625, :gather_same, [:gather_same, :reverse], :≠, -14.46875, :cons, true, -228, true, :args, -472], -14.75, :type, [[:==]]]


# [[-1.3125, :not, true, :"\u2260", :>, [-9.5, :<, 275, 205, [:cdr, [:flip!, :leafmap, :until0], :map, :set, :dict, [false], :types, -2.03125], :cdr, :leafmap, 15.15625, :>, -5.4375, 10.40625, :set], :dup, :or, 219, :eval, :enlist, :concat, :until0, :leafmap, -2.65625, [:split, 13.34375, 1.75, :add, :noop, :if]], :args, true, :>, :==, :dict, :gather_same, false, :split, -224, false, :enlist, 244, :"\u2265", false, :==, :flip!, :gather_same, :not, :types, 3.71875, :not, :noop, :divmod, -12.78125, -501, :and, 284, :until0, :<, -5.625, :subtract, -14.65625, -172, :>, :until0, :is_a?, [[-14.21875, :>, 476, :<, :==, :noop, false, false, 13.1875], []]]


# [[4.4375, :divmod, 308, 398, :until0, :noop, :while, :divmod, false, 2.46875, 174, 300, -273, :if, [:which, :get, false, false, :if, [-5.0625, :car, :not, :is_a?], -30, :≥, :set, :which, :which, :swap], false, :swap, -309, true, -22, [:noop, 15.5625, :noop, [true, :gather_same, [:gather_same, :get, :divide]]]], :cdr, :dup, :dup, :cdr, false, -9.65625, false, true, [:leafmap, :not, :map, :>, :is_a?, :if, :split, -8.53125, :==, :divide], :map, :until0, :>, 71, :multiply, [:enlist, :pop, :leafmap, -8.3125, :enlist, :noop, :gather_same, :gather_same, :==, :until0], false, :==, :is_a?, :get, :<, :map, -3.375, -11, :gather_same, 2.25, :divmod, :types, -467]




  x = Random.rand(100)
  y = 9*x*x - 11*x + 1964






pf = PushForthInterpreter.new(dude,[x])

# (0..1000).each do |i|
#   puts i
#   puts pf.stack.flatten.length
#   pf.step!
#   puts pf.stack.inspect
# end

pf.run(5000,10)
puts pf.stack.inspect