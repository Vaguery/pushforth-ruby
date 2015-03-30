require_relative '../lib/push-forth'
include PushForth

dude = [[15.59375, false, :and, :map, :get, :leafmap, :<, true, 361, :not, :>, -6.84375, :≤, :type, true, 233, -3.5, :if, false, :while, [true, :gather_all, :pop, :get, :map, :multiply, :not, :subtract, 204, -2.125], :leafmap, :is_a?, 285, [-7.5, [:cdr, -293, :until0, :cons, false, :until0, :multiply, -13.71875], :gather_all, -3]], :until0, :noop, :dict, 458, [:cdr, :rotate, true, true, :cdr, :<, :map, :while, :enlist, :divide], [:gather_all, -8, :swap, -13.84375, :if, :concat, -178, :map, -6.5, :subtract], -259, :which, :dup, false, :swap, :pop, :multiply, :enlist, 4.5, [:flip!, false, :rotate, [-388, :car, 1.28125, :dict, :dict, :flip!], :≠]]






pf = PushForthInterpreter.new(dude)

(0..1000).each do |i|
  puts i
  puts pf.stack.flatten.length
  pf.step!
  puts pf.stack.inspect
end