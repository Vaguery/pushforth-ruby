require_relative '../lib/push-forth'
include PushForth

dude = [[0, -388, :while, :multiply, :noop, :==, false, :swap, :noop, :car, :cons, :eval, -394, :or, :concat, :cons, :cdr, :which, false, [-4.75, :add, :dict, :set, :until0, [:rotate, -176, :add, :swap], :<, true, false, :flip!, :multiply, false], true, :eval, -11.375, false, :unit, :<, :get, :while, :divmod, false, 29, [:get]], :set, :eval, -328, :dict, -177, 5.03125, :map, :dict, :subtract, :get, :≠, -368, -441, :while, [9.90625, -229, :pop, :≠, :rotate, [false, -321, :multiply, :dup], :multiply, -3.375, false, :while, :split, :swap], [:while, :leafmap, :dup, [false, 53, -245, :multiply, false, :pop], :dup, :subtract, :get, []]]



pf = PushForthInterpreter.new(dude)

(0..1000).each do |i|
  puts i
  puts pf.stack.flatten.length
  pf.step!
  puts pf.stack.inspect
end