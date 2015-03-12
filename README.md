# pushforth-ruby

Sketch of Maarten Keijzer's push-forth interpreter in Ruby

See [his GECCO 2013 paper](https://www.lri.fr/~hansen/proceedings/2013/GECCO/companion/p1635.pdf) (also available in the [ACM digital library](http://dl.acm.org/citation.cfm?id=2482742&dl=ACM&coll=DL&CFID=487151347&CFTOKEN=91969458) for members and subscribers).

## Adaptations and interpretations

- Maarten's original syntax was very lisp-like in its unadorned instruction tokens. In order to set these off from the background text of the script, I've used Ruby's `Symbol` notation for them, adding an initial colon. This would just be semantic sugar, except that it also helps simplify my interpreter's evaluation loop.
- It was unclear in the original paper whether Maarten intended the interpreter to halt _only_ when the initial token was an empty list, a non-list item, or both. I've tried to be consistent here, and made it explicit that an empty list is popped when executed. This may have consequences downstream that I'm unaware of at this point.
- Maarten's nomenclature with the "pivot" operator is not used here. Maybe when we print stuff, but personally I find it confusing.
- When an instruction would raise an exception (for example, division by 0), instead of failing silently it produces an `Error` object as a result (pushed to the appropriate stack).
- the `i combinator` is called `:enlist`

## Sort of how it works

`push-forth` is a strongly typed functional stack-based language, based roughly on [Push](http://faculty.hampshire.edu/lspector/push.html) and deeply inspired by [Joy](http://en.wikipedia.org/wiki/Joy_\(programming_language\)).

The program code (literals, instructions, and lists composed of those) is initially pushed onto a single stack for execution. The core interpreter cycle consists of repeated imperative applications of the `:eval` instruction on this stack, until a `halt` condition is encountered. Actually, I suppose technically the "halt" is simply an identity, but you want to stop running the thing then because infinity.

Anyway, the rules for `eval` are:

- if the stack is empty, do nothing (and `halt`)
- if the stack starts with a non-list (instruction or other literal), do nothing (and `halt`)
- if the stack starts with an empty list, throw it away
- pop the top item, which must be a non-empty list; call the remaining stack the `data` stack and the one you've popped the `code` stack
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
                        ...
                        [2]
~~~

The interpreter I've written here has a proxy `#step` method which applies `:eval` on the interpreter stack one step at a time until it's done. The `:eval` instruction does its thing on any _arbitrary_ list of tokens, and as a result it can also occur within `push-forth` source code. See below.

## Instructions

Instructions Maarten explicitly mentions in his brief account are (details to follow):

- `:eval`
- `:dup`
- `:swap`
- `:rot`
- `:add` or `:+`
- `:i` combinator
- `:cons`
- `:pop`
- `:split`
- `:car`
- `:cdr`
- `:cat`
- `:unit`
- `:while`
- `:put`
- `:get`
- `:cake`
- `:unpair`
- `:fold`
- `:zap`
- `:π`

These are just a little smattering, more or less presented as telegraphic examples rather than a comprehensive or covering language. Nonetheless, they're sufficient to suggest how more traditional functional forms could be constructed (or _evolved_ from these raw materials and suites of examples, as Maarten demonstrates) or extended with domain-specific types and idioms.