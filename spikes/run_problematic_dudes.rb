require_relative '../lib/push-forth'
include PushForth

dude = [[true, :rotate, :until0, 5.03125, :set, :not, :enlist, :leafmap, false, :map, [:≠, true, 93, true, 379, :concat, :which, :rotate, 17, :==], :≥, :≤, :leafmap, :dup, :>, :add, [8.78125, 91, false, :>, :>, -109, false, -13.5, [:cons], -15.21875, :leafmap, :multiply, :divide, :not, :==, :or, :dict, :==]], :noop, :which, :and, :>, :divide, :set, :dict, :concat, :split, :>, false, :and, :cdr, :and, :dup, false, [:swap, :split, :which, true, :pop, [:pop, -512, :cdr, 14.0625], false, :≤, :swap, 116, :cons, :while], :≠, :divmod, :which, :not, :≠, -14.3125, :car, [225, :flip!, :add, 367, :not, :rotate, :multiply]]


pf = PushForthInterpreter.new(dude)

(0..1000).each do |i|
  puts i
  puts pf.stack.flatten.length
  pf.step!
  puts pf.stack.inspect
end