# pushforth-ruby

This is a "quick" test-driven implementation of Maarten Keijzer's push-forth interpreter in the Ruby language. For the description I'm working from, see [his GECCO 2013 paper](https://www.lri.fr/~hansen/proceedings/2013/GECCO/companion/p1635.pdf) (also available in the [ACM digital library](http://dl.acm.org/citation.cfm?id=2482742&dl=ACM&coll=DL&CFID=487151347&CFTOKEN=91969458) for members and subscribers).

Like many languages designed for use in genetic programming (or as I prefer to say, _generative programming_) settings, `push-forth` is not really for people to read or write. Rather it's designed to be

- extraordinarily robust, in the sense of having only short-range syntactical constraints (like list parentheses matching)
- extraordinarily simple to run, having a single consistent "start" state and a single "step" method that moves interpretation forward to the next state
- readily extensible, with explicit design patterns that help one understand the "reasonable" way to add domain-specific instructions or libraries of types
- [reentrant](http://en.wikipedia.org/wiki/Reentrancy_(computing)), a thing shared by all the "Pushlike" languages

Things `pushforth` is not:
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

I've made some changes, and probably some mistakes

- Maarten's original syntax was very lisp-like in its unadorned instruction tokens. In order to set these off from the background text of the script, I've used Ruby's `Symbol` notation for them, adding an initial colon. This would just be semantic sugar, except that it also helps simplify my interpreter's evaluation loop.
- It was unclear in the original paper whether Maarten intended the interpreter to halt _only_ when the initial token was an empty list, a non-list item, or both. ~~I've tried to be consistent here, and made it explicit that an empty list is popped when executed. This may have consequences downstream that I'm unaware of at this point.~~ Oh, yeah, it seems to make a difference when you get to his note on the `:while` instruction ("Dammit, Maarten!"). So to make it absolutely clear: **A pushforth program evaluates to itself (that is, halts) _unless_ the first item is a non-empty list.**
- Maarten's nomenclature with the "pivot" operator is not used here. Maybe when we print stuff, but personally I find it confusing.
- When an instruction would raise an exception (for example, division by 0), instead of failing silently it produces an `Error` object as a result (pushed to the appropriate stack).
- the `i combinator` is called `:enlist`
- the `:cat` combinator is `:concat`
- as a rule, I've implemented any instruction that wants multiple strongly-typed arguments as able to "scroll forward" as a continuation form

## Sort of how it works

`push-forth` is a strongly typed functional stack-based language, based roughly on [Push](http://faculty.hampshire.edu/lspector/push.html) and deeply inspired by [Joy](http://en.wikipedia.org/wiki/Joy_\(programming_language\)).

The program code (literals, instructions, and lists composed of those) is initially pushed onto a single stack for execution. The core interpreter cycle consists of repeated imperative applications of the `:eval` instruction on this stack, until a `halt` condition is encountered. Actually, I suppose technically the "halt" is simply an identity, but you want to stop running the thing then because infinity.

Anyway, the rules for `eval` are:

- if the stack is empty, starts with a literal (instruction or non-list value) or starts with an empty list, do nothing (and `halt`)
- pop the top item, which _must_ be a non-empty list; call the remaining stack the `data` stack and the one you've popped the `code` stack
  - pop the first element of the `code` stack, setting aside the remaining `code` stack for later
  - if the popped item is a literal or a list, push it onto the `data` stack, followed by the reduced `code` stack
  - if the popped item is an instruction, execute it, then push back the (possibly altered) `code` stack onto the (possibly altered) `data` stack

So for example, the execution of a script `1 1 +` would go like this:

~~~ text
code           active   data
                        [[1, 1, :+]]        initial script on "data" as list
[1, 1, :+]              []                  pop top item from "data"
[1, :+]            1    []                  pop top of "code"
[1, :+]                 [1]                 literal; push onto "data"
                        [[1, :+], 1]        push "code" onto "data"
[1, :+]                 [1]                 pop top item from "data"
[:+]               1    [1]
[:+]                    [1, 1]              literal; push it
                        [[:+], 1, 1]        replace "code"
[:+]                    [1, 1]
[]                 :+   [1, 1]
[]                      [2]                 instruction; apply it
                        [[], 2]             replace "code"
                                            HALT STATE
~~~

The interpreter I've written here has a proxy `#step` method which applies `:eval` on the interpreter stack one step at a time until it's done. The `:eval` instruction does its thing on any _arbitrary_ list of tokens, and as a result it can also occur within `push-forth` source code. See below.

## Instructions

Instructions Maarten explicitly mentions in his brief account are, as I implement them:

- `:eval` signature:(list with a list as its first element)
  - `[[:eval,1,2],3,4,5]` ☛ `[[1,2],3,4,5]`  # arg doesn't match
  - `[[:eval,1,2],[3,4,5]]` ☛ `[[1,2],[3,4,5]]` # arg doesn't match
  - `[[:eval]]` ☛ `[[]]` # no arg
  - `[[:eval,1,2],[[3],4],5]` ☛ `[[1,2],[3,4],5]` # eval a literal: unshift it in context
  - `[[:eval,1,2],[[:add],3,4],5]` ☛ `[[1,2],[7],5]` # eval an instruction in context: run it
  - `[[:eval],[[],3,4],5]` ☛ `[[],[3,4],5]` # do nothing (HALT)
- `:dup` signature:(anything)
  - `[[:dup,1,2],3,4,5]` ☛ `[[1,2],3,3,4,5]`
  - `[[:dup]]` ☛ `[[]]` # fails if no arg
- `:swap` signature:(anything,anything)
  - `[[:swap,1,2],3,4,5]` ☛ `[[1,2],4,3,5]`
  - `[[:swap]]` ☛ `[[]]` # fails if any arg is missing
  - `[[:swap],1]` ☛ `[[],1]`
- `:rotate` signature:(anything,anything,anything)
  - `[[:rotate,1,2],3,4,5]` ☛ `[[1,2],4,5,3]`
  - `[[:rotate]]` ☛ `[[]]` # fails if any arg is missing
  - `[[:rotate],1]` ☛ `[[],1]`
  - `[[:rotate],1,2]` ☛ `[[],1,2]`
- `:add` signature:(Number,Number)
  - `[[:add,1,2],3,4+5i]` ☛ `[[1,2],7+5i]`
  - `[[:add]]` ☛ `[[]]`
  - `[[:add,1,2],"foo",3,4]` ☛ `[[:add,"foo",1,2],3,4]` # continuation form
  - `[[:add,1,2],3,"bar",4]` ☛ `[[:add,"bar",1,2],3,4]` # continuation form
  - `[[:add,1,2],"foo","bar",3,4]` ☛ `[[1,2],"foo","bar",3,4]` # fails if no arg matches
- `:enlist` signature:(list)
  - `[[:enlist,1,2],[3,4],5,6]` ☛ `[[1,2,3,4],5,6]`  # appends a list to the code stack
  - `[[:enlist],3,4]` ☛ `[[],3,4]`  # fails if arg doesn't match
  - `[[:enlist],[[3,[4]]],5,6]` ☛ `[[[3,[4]]],5,6]`
- `:cons` signature:(anything,list)
  - `[[:cons,1,2],3,[4]]` ☛ `[[1,2],[3,4]]` # prepends 1st arg onto list arg
  - `[[:cons]]` ☛ `[[]]` # fails if no 1st arg
  - `[[:cons],3,"foo",[4]]` ☛ `[[:cons,"foo"],3,[4]]` # uses a continuation form if 1st arg matches
- `:pop` signature:(anything)
  - `[[:pop,1,2],3,4,5]` ☛ `[[1,2],4,5]` # discards next item
  - `[[:pop,1,2]]` ☛ `[[1,2]]` # fails if no arg
- `:split` signature:(list)
  - `[[:split,1,2],[3,4,5]]` ☛ `[[1,2],3,[4,5]]` # pop and retain top item of arg
  - `[[:split],1,[2,3]]` ☛ `[[],1,[2,3]]` # fails if arg is not a list
  - `[[:split],[]]` ☛ `[[],[]]` # no net effect if arg is empty (vs `:car`)
- `:car` signature:(list)
  - `[[:car,1,2],[3,4,5]]` ☛ `[[1,2],3]` # pop and retain ONLY top item of arg
  - `[[:car],1,[2,3]]` ☛ `[[],1,[2,3]]` # fails if arg is not a list
  - `[[:car],[]]` ☛ `[[]]` # deletes an empty arg
- `:cdr` signature:(list)
  - `[[:cdr,1,2],[3,4,5]]` ☛ `[[1,2],[4,5]]` # pop and discard top item of arg
  - `[[:cdr],1,[2,3]]` ☛ `[[],1,[2,3]]` # fails if arg is not a list
  - `[[:cdr],[]]` ☛ `[[]]` # deletes an empty arg
- `:concat` signature:(list,list)
  - `[[:concat,1,2],[3,4],[5,6]]` ☛ `[[1,2],[3,4,5,6]]` # combine two list args
  - `[[:concat],1,2]` ☛ `[[],1,2]` # fail if no arg matches
  - `[[:concat],1,[2,3],[4]]` ☛ `[[:concat,1],[2,3],[4]]` # continuation form
  - `[[:concat],[1],2,[3,4]]` ☛ `[[:concat,2],[1],[3,4]]` # continuation form
  - `[[:concat],[],[1,2]]` ☛ `[[],[1,2]]` # fine with empty list
  - `[[:concat],[],[]]` ☛ `[[],[]]` # even when both args are empty
- `:unit` signature:(list)
  - `[[:unit,1,2],[3,4,5]]` ☛ `[[1,2],[3],[4,5]]` # pop and wrap top item in arg
  - `[[:unit],1]]` ☛ `[[],1]` # fail if arg is not a list
  - `[[:unit],[]]` ☛ `[[],[],[]]` # create a new empty list if arg empty
  - `[[:unit],[712]]` ☛ `[[],[712],[]]` # …or if it has 1 element
- `:while`
- `:put`
- `:get`
- `:cake`
- `:unpair`
- `:fold`
- `:zap`
- `:π`

These are just a little smattering, more or less presented as telegraphic examples rather than a comprehensive or covering language. Nonetheless, they're sufficient to suggest how more traditional functional forms could be constructed (or _evolved_ from these raw materials and suites of examples, as Maarten demonstrates) or extended with domain-specific types and idioms.

For example, here are some more instructions I've added to flesh it out:

- `:subtract` signature:(Number,Number)
  - `[[:subtract,1,2],3,4+5i]` ☛ `[[1,2],-1+5i]`
  - `[[:subtract]]` ☛ `[[]]`
  - `[[:subtract,1,2],"foo",3,4]` ☛ `[[:subtract,"foo",1,2],3,4]` # continuation form
  - `[[:subtract,1,2],3,"bar",4]` ☛ `[[:subtract,"bar",1,2],3,4]` # continuation form
  - `[[:subtract,1,2],"foo","bar",3,4]` ☛ `[[1,2],"foo","bar",3,4]` # fails if no arg matches
- `:multiply` signature:(Number,Number)
  - `[[:multiply,1,2],3,4+5i]` ☛ `[[1,2],12+15i]`
  - `[[:multiply]]` ☛ `[[]]`
  - `[[:multiply,1,2],"foo",3,4]` ☛ `[[:multiply,"foo",1,2],3,4]` # continuation form
  - `[[:multiply,1,2],3,"bar",4]` ☛ `[[:multiply,"bar",1,2],3,4]` # continuation form
  - `[[:multiply,1,2],"foo","bar",3,4]` ☛ `[[1,2],"foo","bar",3,4]` # fails if no arg matches
- `:divide` signature:(Number,Number)
  - `[[:divide,1,2],3,4+5i]` ☛ `[[1,2],7+5i]`
  - `[[:divide,1,2],3,0]` ☛ `[[1,2],Error("div0")]` # produces an `Error` result
  - `[[:divide]]` ☛ `[[]]`
  - `[[:divide,1,2],"foo",3,4]` ☛ `[[:divide,"foo",1,2],3,4]` # continuation form
  - `[[:divide,1,2],3,"bar",4]` ☛ `[[:divide,"bar",1,2],3,4]` # continuation form
  - `[[:divide,1,2],"foo","bar",3,4]` ☛ `[[1,2],"foo","bar",3,4]` # fails if no arg matches

And here are the types I've encountered so far:
- `Numeric`: using Ruby's built in for the moment, without being too concerned about the error-producing overflows and such; will let the execution of random pushforth programs "stress-test" these definitions and tell me whether I need to capture exceptions on the fly or try to plan ahead for them
- `Error`: records a "runtime" error generated by pushforth, like `div0`
- `Boolean`
- `Instruction`
- `List`

And the types I expect to want in fleshing things out:
- `String`
- `Iterator`
- some kind of key-value hash