Gem::Specification.new do |s|
  s.name        = 'pushforth'
  s.version     = '0.1.2'
  s.date        = '2015-05-13'
  s.summary     = "pushforth interpreter in Ruby"
  s.description = "Interpreter for Bill Tozier's variant of Maarten Keijzer's pushforth language for genetic programming."
  s.authors     = ["Bill Tozier"]
  s.email       = 'bill@williamtozier.com'
  s.files       = ["lib/pushforth_interpreter.rb","lib/pf_arithmetic.rb","lib/pf_boolean.rb","lib/pf_comparison.rb","lib/pf_dictionary.rb","lib/pf_functional.rb","lib/pf_list.rb","lib/pf_miscellaneous.rb","lib/pf_range.rb","lib/pf_types.rb","lib/pf_script.rb"]
  s.homepage    = 'https://github.com/Vaguery/pushforth-ruby'
  s.license       = 'MIT'
end