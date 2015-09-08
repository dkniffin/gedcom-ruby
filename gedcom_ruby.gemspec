Gem::Specification.new do |s|
  s.name        = 'gedcom_ruby'
  s.version     = "0.3.1"
  s.date        = '2015-08-31'
  s.summary     = "A Ruby library for easily doing custom, callback-based GEDCOM parsing"
  s.description = "This is a module for the Ruby language that defines a callback GEDCOM parser. It does not do any validation of a GEDCOM file, but, using application-defined callback hooks, can traverse any well-formed GEDCOM."
  s.authors     = ["Derek Kniffin", "Phillip Davies"]
  s.email       = 'derek.kniffin@gmail.com'
  
  s.files       = `git ls-files -- lib/*`.split("\n")
  s.test_files  = `git ls-files -- spec/*`.split("\n")

  s.homepage    = 'https://github.com/dkniffin/gedcom-ruby'
  s.license     = 'GNU LESSER GENERAL PUBLIC LICENSE'

  s.add_development_dependency "rspec", '~> 3.3', '>= 3.3.0'
  s.add_development_dependency "byebug", '~> 3.3', '>= 3.3.0'
end
