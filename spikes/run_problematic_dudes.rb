require_relative '../lib/push-forth'
include PushForth

dude = [[4.4375, :divmod, 308, 398, :until0, :noop, :while, :divmod, false, 2.46875, 174, 300, -273, :if, [:which, :get, false, false, :if, [-5.0625, :car, :not, :is_a?], -30, :≥, :set, :which, :which, :swap], false, :swap, -309, true, -22, [:noop, 15.5625, :noop, [true, :gather_same, [:gather_same, :get, :divide]]]], :cdr, :dup, :dup, :cdr, false, -9.65625, false, true, [:leafmap, :not, :map, :>, :is_a?, :if, :split, -8.53125, :==, :divide], :map, :until0, :>, 71, :multiply, [:enlist, :pop, :leafmap, -8.3125, :enlist, :noop, :gather_same, :gather_same, :==, :until0], false, :==, :is_a?, :get, :<, :map, -3.375, -11, :gather_same, 2.25, :divmod, :types, -467]




  x = Random.rand(100)
  y = 9*x*x - 11*x + 1964






pf = PushForthInterpreter.new(dude,[x])

(0..1000).each do |i|
  puts i
  puts pf.stack.flatten.length
  pf.step!
  puts pf.stack.inspect
end