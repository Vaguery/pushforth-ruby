Gem::Specification.new do |s|
  s.name        = 'pushforth'
  s.version     = '0.0.1'
  s.date        = '2015-05-09'
  s.summary     = "pushforth interpreter in Ruby"
  s.description = "Interpreter for Bill Tozier's variant of Maarten Keijzer's pushforth language for genetic programming."
  s.authors     = ["Bill Tozier"]
  s.email       = 'bill@williamtozier.com'
  s.files       = ["lib/pushforth.rb","lib/pf-arithmetic.rb","lib/pf-boolean.rb","lib/pf-comparison.rb","lib/pf-dictionary.rb","lib/pf-functional.rb","lib/pf-list.rb","lib/pf-miscellaneous.rb","lib/pf-range.rb","lib/pf-types.rb"]
  s.homepage    = 'https://github.com/Vaguery/pushforth-ruby'
  s.license       = 'MIT'
end