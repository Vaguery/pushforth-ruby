require_relative '../lib/push-forth'
include PushForth

dude = [[[false, :map, -14.5, false, :dict, :set, :dict, :add, 177, :which], -385, true, :do_times, :dict, :wrapitup, :multiply, [:not, [:rotate, -13.46875, :noop, :dict, :gather_same, false, true, :>], :args, :divide], :while, :become, :args, :flip!, :≤, false, :wrapitup, :noop, :leafmap, -12.34375, :leafmap, :not, :and, -3.5, :unit, 2.78125, true], :multiply, 149, [:become, :not, :dict, false, 0.90625, :type, :≥, true, :==, [], :divmod, -136, false, [:later, :snapshot, -142, -377, [:gather_all], :add, :while, 384, 324], :==, :enlist, -2.65625, :types, false], :and, -12.84375, :≤, :multiply, :while, false, :later, 44, :noop, :type, :divide, :which, :>, true] # appeared to produce multiple Dictionaries with same object_id, but not replicable...


# [[310, :and, :later, 0.3125, :divide, :gather_all, [:divmod, :wrapitup, :==, :dict, :eval, :henceforth, :split, -3.71875, :map, -10.78125], :unit, :not, :args, 10.5, 10.1875, :cdr, :dict, :set, :eval, -2.84375, :add, :henceforth, 6.90625, :while, :≠, false, 12.1875, :type, true, :gather_all, :<, 414, 347, :split, false, :later, :gather_same, :become, :divide, [[-240]]], -13.4375, -322, :≤, 408, 457, false, -189, :≠, false, -17, -432, :is_a?, [-1.5625, false, :pop, 265, -0.40625, -8.03125, :args, -34, [-8.09375], :args, :subtract, :<, [:eval, :not, true, 7.9375, 0.21875], [:noop, :is_a?, 14.09375, [], :while, false, :args, :type, -5.6875, false], [14.625, :gather_same]]]


# [[-8.03125, 1.75, [-10.8125, :args, :dup, true, [false, :until0, :dict, :do_times, :pop], -12.40625, -0.9375, 361, :is_a?, 323], :and, -13.875, :set, false, :≤, 423, :dict, :gather_all, :swap, :≤, :or, 3.65625, [[-400, :map, :rotate, -12.875, :gather_same, false, :gather_same, :if, -15.875], 48], :==, false, :henceforth, :gather_same], :args, :≥, :leafmap, -7.0, :snapshot, :gather_same, :gather_same, true, :become, :reverse, false, :become, 12.375, [:leafmap, :swap, -49, :eval, true, :==, :wrapitup, :rotate, [:type], -13, :args, [:again, :multiply, :concat, :or, :==, :get], 6.25, 328, :unit, :until0], -27, :not, true, :get, :become, :args, true, -463, [:≥]]


# [[145, :>, :≥, :later, true, :which, :type, :while, :≥, :args, :divide, :reverse, false, :concat, true, :map, :henceforth, 466, :concat, :dict, :split, -404, :noop, :swap, -306, :enlist, :later, false, -9, :≥, -500, :snapshot, :later, :and, [[-176, [-13.75, :≥, [[265, 1.09375, false], [], :car, :<], :rotate, :leafmap, :set], -1.53125], :cdr, :if, :>, [], :enlist, :map, -13.5, false, :reverse, 7.34375, true, :later, :dup, :is_a?], 3.59375, 4.0625, :≠, 14.53125, :if, :enlist, :wrapitup, -271, 346, [-132, :≤, :type, :gather_all, :<, :noop, :map, false, :reverse, :and], :gather_same, :dup, [:type, 8.5625, :henceforth, -14.3125, :until0, :≥, :leafmap, :flip!, -7.625, :≤], :again, :divmod, [-426, [:divmod, false, -2.90625, :rotate, false, true, [3.4375], :divide, :wrapitup], [:args, :become, :car, :wrapitup, :noop, :swap], -174, :later, :split, 3.4375], :car, :divmod, -279, :get, :henceforth, :cdr, :or, -2.1875, :while, :>, 12.375, 227, false, 6.84375, :which, :reverse, :flip!, 390, :while, true, :again, :cons, 5.21875, :cdr, :gather_all, :split, [:wrapitup, true, :<, -369, :gather_all, -395, [[:is_a?, false], -13.21875, [:wrapitup, [false, :cons, false], [], -4.15625, :≠, [:multiply], 6.03125, -10.84375], 10.46875, [:types, [], [:types, :noop], :==, :later, -15.6875, false, :map], true, :cons], false], 100, 10.40625, :pop, :type, [true, :rotate, :swap, :henceforth, :is_a?, false, :set, :enlist, true, [], -10.71875, :reverse, :until0, 142, [:dup, :gather_same, true, :cons, :pop], :<, -366, :dict, [:reverse], :which, :add, :eval, :cons, :cons, :≤, :eval, :unit, true], [:later, :≠, -7, 5.65625, :divmod, true, 1.3125, false, :types, :set], -69, :which, :henceforth, :cons, 14.75, :dup, false, false, :multiply, 458, false, true, :and, false, [:unit, true, -9.5, -3.0625, :later, -8.65625, [[0.4375, :wrapitup], true, 13.875, false, -14.90625, false]]], :≤, 137, [:later, :get, -14.53125, -214, :eval, 11.3125, :≠, -178, true, true], :noop, true, [410, :leafmap, 3.75, false, -13.28125, -12.4375, [471, :map, :rotate], :flip!, 93, [[[true, 15.0625], :later, :gather_same, :<, 9.59375, -9.96875, -10.59375], :and], -62], true, [34, false, false, 72, false, false, :wrapitup, :cdr, [269], :become, :snapshot, true, 58, 5.34375, false, 4.03125, :type, :cdr], 115, 10.5625, :noop, :car, 11.59375, -55, :subtract, -303, [[492, -9.8125, [:reverse, :types, false, 0.53125, 215, :not], 375], :==, -337, -3.125], :set, :map, :add, :or, -489, [:enlist, :≥, :if, :divmod, 174, -144, :concat, 96, [:snapshot], :subtract, :multiply, :<, :get, 379, -6.28125, [:eval, :dict], :split, :dict, :leafmap, -13.03125, false, :enlist, :leafmap, -4.125], :rotate, -11.25, -457, :henceforth, -317, [-47, :while, :wrapitup, :until0, 9.8125, false, :which, :leafmap, 2.6875, :dup], 295, :≥, [:rotate, -212, 12.59375, -1.28125, :add, :eval, :dict, :subtract, :snapshot, false], :until0, -74, :later, :gather_same, [[:swap, [:rotate, true, :<, false, 203, 2.6875, :if], :not], -5.4375, :leafmap], :<, 11.75, :cdr, [[:divmod, false, :divmod, [:args, :>, 275, :set, :flip!], -13.78125], :henceforth, :eval, -188, :type], 8.25, [:type, [true, -11.9375, -44, 118, :≥, false, :<, :subtract], :split, [], :wrapitup, 15.65625, [:dict, :while, -459, 23, :eval, true, -5.15625], :types, :swap, -5.15625], :type, false, 10.25, 14.4375, :cons, 118, [false, :==, :type, 115, :cdr, 278, false, :not, :args, false], true, [:is_a?, :leafmap, 232, :split, 10.3125, [false, 11.0, :cons, :get], :multiply, :dup, :concat, -375, 467, :flip!], -4.6875, :≠, :add, 15.3125, :add, -3.71875, :split, :add, [5.375, [[:>, :unit, true, true, -4.84375, :while, :while], [:not], -13.75]]]


# [[:<, :get, :rotate, :and, 138, :dict, :unit, true, -14.0625, -362, -65, -1.0, :type, -3.4375, :type, :concat, :until0, true, true, :map, :divmod, :multiply, :again, :split, true, true, false, -225, :≠, :snapshot, [326, :wrapitup, :rotate, false, :snapshot, :henceforth, false, -41, :args, :<], -147, [7.6875, :later, [-309, :again, :concat]]], :cons, true, [:gather_all, 114, :type, -496, :is_a?, 5.78125, :==, -12.5625, :not, :get], true, :wrapitup, true, :snapshot, false, :rotate, :swap, -10.1875, :snapshot, -7.875, [:set, 15.71875, :cdr, :is_a?, :flip!, -0.40625, :gather_same, [:gather_same, :reverse], :≠, -14.46875, :cons, true, -228, true, :args, -472], -14.75, :type, [[:==]]]


# [[-1.3125, :not, true, :"\u2260", :>, [-9.5, :<, 275, 205, [:cdr, [:flip!, :leafmap, :until0], :map, :set, :dict, [false], :types, -2.03125], :cdr, :leafmap, 15.15625, :>, -5.4375, 10.40625, :set], :dup, :or, 219, :eval, :enlist, :concat, :until0, :leafmap, -2.65625, [:split, 13.34375, 1.75, :add, :noop, :if]], :args, true, :>, :==, :dict, :gather_same, false, :split, -224, false, :enlist, 244, :"\u2265", false, :==, :flip!, :gather_same, :not, :types, 3.71875, :not, :noop, :divmod, -12.78125, -501, :and, 284, :until0, :<, -5.625, :subtract, -14.65625, -172, :>, :until0, :is_a?, [[-14.21875, :>, 476, :<, :==, :noop, false, false, 13.1875], []]]


# [[4.4375, :divmod, 308, 398, :until0, :noop, :while, :divmod, false, 2.46875, 174, 300, -273, :if, [:which, :get, false, false, :if, [-5.0625, :car, :not, :is_a?], -30, :≥, :set, :which, :which, :swap], false, :swap, -309, true, -22, [:noop, 15.5625, :noop, [true, :gather_same, [:gather_same, :get, :divide]]]], :cdr, :dup, :dup, :cdr, false, -9.65625, false, true, [:leafmap, :not, :map, :>, :is_a?, :if, :split, -8.53125, :==, :divide], :map, :until0, :>, 71, :multiply, [:enlist, :pop, :leafmap, -8.3125, :enlist, :noop, :gather_same, :gather_same, :==, :until0], false, :==, :is_a?, :get, :<, :map, -3.375, -11, :gather_same, 2.25, :divmod, :types, -467]




  x = Random.rand(100)
  y = 9*x*x - 11*x + 1964






pf = PushForthInterpreter.new(dude,[81])

# (0..1000).each do |i|
#   puts i
#   puts pf.stack.flatten.length
#   pf.step!
#   puts pf.stack.inspect
# end

pf.run(step_limit:5000,time_limit:60,size_limit:5000,trace:true)
puts pf.stack.inspect