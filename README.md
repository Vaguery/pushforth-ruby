# pushforth-ruby

This was originally intended to be a "quick" test-driven implementation of Maarten Keijzer's `push-forth` interpreter in the Ruby language, though it's quickly blooming into a typical Push-like language implementation. For the description I'm working from, see [his GECCO 2013 paper](https://www.lri.fr/~hansen/proceedings/2013/GECCO/companion/p1635.pdf) (also available in the [ACM digital library](http://dl.acm.org/citation.cfm?id=2482742&dl=ACM&coll=DL&CFID=487151347&CFTOKEN=91969458) for members and subscribers).

Like many languages designed for use in genetic programming (or as I prefer to say, _generative programming_) settings, `pushforth-rb` is not really intended for human beings to _read_ or even _write_. Rather it's designed to be

- extraordinarily robust, in the sense of having only short-range syntactical constraints (like list parentheses matching)
- extraordinarily simple to run, having a single consistent "start" state and a single "step" method that moves interpretation forward to the next state
- readily extensible, with explicit design patterns that help one understand the "reasonable" way to add domain-specific instructions or libraries of types
- [reentrant](http://en.wikipedia.org/wiki/Reentrancy_(computing)), a thing shared by all the "Pushlike" languages

Things `pushforth-rb` is not:
- legible
- easy to follow what's happening
- "reasonable" when you look at how programs work

That said, it's not an "esoteric" language, in the sense of [malbolge](http://en.wikipedia.org/wiki/Malbolge) or [INTERCAL](http://en.wikipedia.org/wiki/INTERCAL), but actually is intended to be a form of _evolvable low-level code_. For example, in his first paper on the language, Maarten demonstrates (though in his typical offhand style) that rather complex but core pieces of "normal" programming languages can be _evolved_ in `pushforth` from the raw materials he provides, based only on a suite of acceptance tests as targets.

Since many folks still don't quite "get" generative programming approaches, let me clarify that for a second (see any good book on generative programming for way more detail than you want):
- the "user" builds a suite of automated rubrics or "expectations", which sum up the desired code's behavior; think of these as being like [RSpec's](http://rspec.info) "expectations": "given state X, I expect state Y to result"
- a few hundred _random_ programs in `pushforth` can be generated
- because the language is robust and flexible, those can be expected to run, and they are passed the initial "state X" from the rubrics as arguments
- when each "guess" is finished running, the resulting state is compared to the desired "state Y"
- "grade" the code, and make _more random code that takes into account the scores of the code you've already run_

That last step is, of course, the entire body of work in the field called "genetic programming", but it's not rocket science. You can use any heuristic or metaheuristic you like, as long as it's able to learn from experience: hill-climbing, population-based evolutionary search, particle swarms, whatever you like. If you're worried about the results being too complicated or convoluted, then make it a multiobjective search and keep the complexity down as well as the error. Boom, you're done (...eventually).

The point is, these stupid unreadable little languages that _run_ and _do something_ even when you insert or delete arbitrary code have a very different use case from the readable, rational languages you may be used to.

## Adaptations and interpretations

I've made a lot of minor changes, and probably some deep mistakes with bad consequences...

- Maarten's original syntax was very lisp-like in its unadorned instruction forms. In order to set these off from the background text of the script, I've used Ruby's `Symbol` notation for them, adding an initial colon. This would just be semantic sugar, except that it also helps simplify my interpreter's evaluation loop.
- Maarten's nomenclature with the "pivot" operator is not used here. Maybe when we print stuff, but personally I find it confusing.
- When an instruction would raise an exception (for example, division by 0 or looking up an item in a Dictionary that doesn't exist), instead of failing silently it produces an `Error` object, which is treated as the actual output.
- various instruction names have been changed from Keijzer's (and von Thun's): the `i combinator` is called `:enlist`; the `:cat` combinator is `:concat`, etc
- as a rule, I've implemented any instruction that wants multiple strongly-typed arguments as able to "scroll forward" as a continuation form; unlike Maarten's description, I've changed it so the

## Sort of how it works

**preliminary version removed because it's totally wrong now**

## Instructions

**preliminary version removed because it's totally wrong now**

- `:<`
- `:==`
- `:>`
- `:add`
- `:again`
- `:and`
- `:args`
- `:become`
- `:car`
- `:cdr`
- `:concat`
- `:cons`
- `:depth`
- `:dict`
- `:divide`
- `:divmod`
- `:do_times`
- `:dup`
- `:enlist`
- `:eval`
- `:flip!`
- `:gather_all`
- `:gather_same`
- `:get`
- `:henceforth`
- `:if`
- `:is_a?`
- `:later`
- `:leafmap`
- `:length`
- `:map`
- `:merge`
- `:multiply`
- `:noop`
- `:not`
- `:or`
- `:points`
- `:pop`
- `:reverse`
- `:rotate`
- `:set`
- `:snapshot`
- `:split`
- `:subtract`
- `:swap`
- `:type`
- `:types`
- `:unit`
- `:until0`
- `:which`
- `:while`
- `:wrapitup`
- `:≠`
- `:≤`
- `:≥`

## A silly list of possibilities and wants

### i/o
- `:emit`

### interpreter
- `:spawn`

### introspection
- `:steps`
- `:errors`
- `:variables`
- `:code_size`
- `:data_size`

### aggregation
- `:bury_type`
- `:bury_same`
- `:archive`
- `:snapshot`

### functional
- `:fold` (see below)
- `:reduce`

### type
- `:same_type?`
- `:yank_args`

### ideas from von Thun's Joy

Some ideas from [von Thun's introduction to the Joy language (PDF)](http://www.complang.tuwien.ac.at/anton/euroforth/ef01/thun01.pdf) make a lot of sense, too.

- `:signum` (`sgn`)
- `:pred` predecessor, for integers, characters, strings
- `:succ` successor
- various `Set` operators
- `:reverse`
- `:swons`
- `:first`
- `:rest`
- `:at`
- `:size` (length)
- `:empty?` (was `:null`)
- `:small?`: `true` if the length of a collection is 0 or 1
- `:get` and `:put`, which in Joy are I/O instructions, not `Dictionary` things
- `:filter`
- `:step` (items from collections)
- `:constr12`
- `:define` (was `:==`, means "define")
- `:linrec` (_hugely_ risky and interesting in genetic programming contexts)
- `:binrec` (ditto)
- `:split` (a filtering list combinator)
- `:dip` "This combinator expects a quotation on top of the stack and below that another value. It pops the two, saving the value somewhere, executes the quotation, and then restores the saved value on top. So, for example, `[swap] dip` will interchange the second and third element on the stack."
- `:powerlist`
- `:mk_qsort`
- the `un` versions of `:cons` and `:swons` and so forth...

### Types

And here are the types I've encountered so far:
- `Numeric`: using Ruby's built in for the moment, without being too concerned about the error-producing overflows and such; will let the execution of random pushforth programs "stress-test" these definitions and tell me whether I need to capture exceptions on the fly or try to plan ahead for them
- `Error`: records a "runtime" error generated by pushforth, like `div0`
- `Boolean`
- `Instruction`
- `List`
- `Dictionary`

And the types I expect to want in fleshing things out:
- `String`
- `Character`
- `Iterator`
- `Type`
- `Set`
