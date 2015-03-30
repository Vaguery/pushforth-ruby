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
whole script: [[1, 1, :+], 44] # the '44' is there as a placeholder
               ^^^^^^^^^^  ^^
                "code"     "data"

code           active   data
                        [[1, 1, :+], 44]   
[1, 1, :+]              [44]                isolate "code" stack
[1, :+]            1    [44]                pop top of "code"
[1, :+]                 [1, 44]             literal; push onto "data"
[:+]               1    [1, 44]
[:+]                    [1, 1, 44]          literal; push it
[]                 :+   [1, 1, 44]
[]                      [2, 44]             instruction; find args on "data"
                        [[], 2]             replace "code"
                                            HALT STATE
~~~

The interpreter I've written here has a proxy `#step` method which applies `:eval` on the interpreter stack one step at a time until it's done. The `:eval` instruction does its thing on any _arbitrary_ list of tokens, and as a result it can also occur within `pushforth` source code. See below.

## A more complex example

Maarten's paper outlines a little `push-forth` interpreter written in `push-forth`. [Here it is, as a sort of over-ambitious acceptance test](https://gist.github.com/Vaguery/f2fcf15496720419146c), running itself running a script that adds 1+1. In other words: the interpreter "runs" an interpreter "running" `[[1, 1, :add]]`

## Instructions

Instructions Maarten explicitly mentions in his brief account are, as I implement them:

- `:eval` signature:(list with a list as its first element)
  - `[[:eval,1,2],3,4,5]` ☛ `[[1,2],3,4,5]`  # arg doesn't match
  - `[[:eval,1,2],[3,4,5]]` ☛ `[[1,2],[3,4,5]]` # arg doesn't match
  - `[[:eval]]` ☛ `[[]]` # no arg
  - `[[:eval,1,2],[[3],4],5]` ☛ `[[1,2],[[],3,4],5]` # eval a literal: unshift it in context
  - `[[:eval,1,2],[[:add],3,4],5]` ☛ `[[1,2],[[],7],5]` # eval an instruction in context: run it
  - `[[:eval],[[],3,4],5]` ☛ `[[],[[],3,4],5]` # do nothing (HALT in the local context)
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
- `:while` signature:(3 lists)
  - `[[:while]]` ☛ `[[]]`
  - `[[:while],1]` ☛ `[[]]`
  - `[[:while],1,1]` ☛ `[[]]`
  - `[[:while],1,1,1]` ☛ `[[]]`
  - etcetera; there is no continuation form (for now) for `:while`
  - `[[:while],[1],[2],[3]]` ☛ `[[1, [[1], :while], :enlist], [3]]`
  - **the interpreter** `[[[[]],[:eval,:dup,:car],:while],[[1,1,:add]]]` ☛ ☛ ☛ ... (many steps later) ☛ ☛ ☛ `[[], [], [[], 2]]`
- `:put`
- `:get`
- `:cake`
- `:unpair`
- `:fold`
- `:zap`
- `:π`

These are just a little smattering, more or less presented as telegraphic examples rather than a comprehensive or covering language. Nonetheless, they're sufficient to suggest how more traditional functional forms could be constructed (or _evolved_ from these raw materials and suites of examples, as Maarten demonstrates) or extended with domain-specific types and idioms.

For example, here are some more instructions I've added to flesh it out:

### arithmetic
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

### boolean
- `:and` signature:(Boolean,Boolean), with continuation form 
- `:or` signature:(Boolean,Boolean), with continuation form
- `:not` signature:(Boolean)
- `:if` signature:(Boolean,Any), with continuation form
  - `[[:if],false,3,4]` ☛ `[[],4]`
  - `[[:if],true,3,4]` ☛ `[[],3,4]` 
  - `[[:if],77,3,4]` ☛ `[[:if,77],3,4]` 
- `:which` signature:(Boolean,Any,Any), with continuation form
  - `[[:which],false,3,4]` ☛ `[[],4]`
  - `[[:which],true,3,4]` ☛ `[[],3]`
  - `[[:which],"foo",3,4,5]` ☛ `[[:which,"foo"],3,4,5]`

### dictionary
- `:get`: signature:(Dictionary,Any), with continuation form
  - `[[:get],«Dictionary:{3:88}»,3]` ☛ `[[],88,«Dictionary:{3:88}»]` (keeps Dictionary)
  - `[[:get],3,4,5]` ☛ `[[:get,3],4,5]`
  - `[[:get],«Dictionary:{3:88}»,4]` ☛ `[[],«Error:key not found»]`
- `:set`: signature:(Dictionary,Any,Any), with continuation form
  - `[[:set],«Dictionary:{3:88}»,3,4]` ☛ `[[],«Dictionary:{3:4}»]`
  - `[[:set],«Dictionary:{3:88}»,:add,false]` ☛ `[[],«Dictionary:{3:4,:add:false}»]`
  - `[[:set],3,4,5]` ☛ `[[:set,3],4,5]`
  - `[[:set],«Dictionary:{3:88}»,4]` ☛ `[[],«Dictionary:{3:88}»,4]`
- `:dict`: signature:()
  - `[[:dict],1,2,3]` ☛ `[[],«Dictionary:{}»,1,2,3]`
- `:keys`: signature:(Dictionary) (machine order)
  - `[[:keys],«Dictionary:{3:88}»]` ☛ `[[],[3],«Dictionary:{3:88}»]`
- `:values`: signature:(Dictionary) (machine order)
  - `[[:values],«Dictionary:{3:88}»]` ☛ `[[],[88],«Dictionary:{3:88}»]`

### numerical comparison
- `:>` (for the moment, greater-than and less-than relations fail for `Complex` numbers)
- `:≥`
- `:<`
- `:≤`
- `:==` (works for all `Number` types)
- `:≠` (works for all `Number` types)


### functional
- `:map` signature: (Any, Any) "applies" the first argument to the second one by interspersing copies of the second between the first on the `:code` stack 
  - `[[:map],3,4,5]` ☛ `[[3,4],5]`
  - `[[:map,1,2],[3],[:dup,[4]],5]` ☛ `[[3,:dup,[4]],5]`
  - `[[:map,1,2],3,[:add],4,5]` ☛ `[[3,:add],4,5]`
- `:until0`: signature: (Positive Integer,List,List)
  - (based on von Thun's :primrec`) Primitive recursion, using a positive integer to count down to 0; uses continuation form
  - `[[:until0],1,[1],[:add]]` ☛ `[[:add, [:add], [1], 0, :until0]]`
  - `[[:until0],0,[1],[:add]]` ☛ `[[1]]`
  - `[[:until0],-1,[1],[:add]]` ☛ `[[],-1,[1],[:add]]`
  - `[[:until0],-1,1,[:add]]` ☛ `[[],-1,[1],[:add]]`
  - `[[:until0],7,1,[:add],[2]]` ☛ `[[:until0,1],7,[:add],[2]]`
  - `[[:until0],7,[1],:add,[2]]` ☛ `[[:until0,:add],7,[1],[2]]`
  - `[[:until0],7,1,:add,[2],[3]]` ☛ `[[:until0,1,:add],7,[2],[3]]`
- `:leafmap` signature: (Any, List)
  - was von Thun's `:treerec`
  - `[[:leafmap],[3,[4]],5]` ☛ `[[3,5,[4,5]]]`
  - `[[:leafmap,1,2],[3],[:dup,[4]],5]` ☛ `[[3,:dup,[4],1,2],5]`
  - `[[:leafmap],[1,[2,[3]]],:foo]` ☛ `[[1, :foo, [2, :foo, [3, :foo]]]]`

### it made sense at the time

- `:flip!`: signature:(N/A); switches the positions of the `code` and `data` portions of the running interpreter state
  - `[[:flip!],3,4,5]` ☛ `[[3,4,5]]`
  - `[[:flip!,1,2],3,4]` ☛ `[[3,4],1,2]`
- `:reverse`


### i/o

- `:args`: takes whatever is in the attribute `PushInterpreter#args` and puts it onto the top of the stack

### type

- `:type`: returns the (leaf) Type of the arg
- `:types`: returns a list containing all the Types of the arg
- `:is_a?`: takes a Type and anything, and returns a Boolean indicating if arg2 is an arg1
- `:gather_all`: takes a Type as an arg, and moves all items in the stack of that Type into a List it puts at the top of the stack
- -`:gather_same`: takes any item as an arg, and moves it and all items other in the stack of that into a List it puts at the top of the stack

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
