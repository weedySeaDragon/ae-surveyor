# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "surveyor/version"

Gem::Specification.new do |s|
  s.name = %q{surveyor}
  s.version = Surveyor::VERSION

  s.authors = ["Ashley Engelund", "Brian Chamberlain", "Mark Yoon"]
  s.email = %q{ashley@ashleycaroline.com yoon@northwestern.edu}
  s.homepage = %q{http://github.com/weedySeaDragon/ae-surveyor}
  s.post_install_message = %q{Thanks for using surveyor! Remember to run the surveyor generator and migrate your database, even if you are upgrading.}
  s.summary = %q{A rails (gem) plugin to enable surveys in your application}

  s.files = Dir["{app,config,db,doc,lib}/**/*"]  + Dir['tasks/*.rake'] + ["MIT-LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]

  #s.files         = `git ls-files`.split("\n") - ['irb']

  s.test_files    = `git ls-files -- {test,spec}/*`.split("\n")

  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('rails', '>= 4')
  s.add_dependency('haml', '~> 4.0')
  s.add_dependency('sass')
  s.add_dependency('formtastic', '~> 2.2.1') # 2.1 requries actionpack 3.0
  s.add_dependency('uuidtools', '~> 2.1')
  s.add_dependency('mustache', '~> 0.99')
  s.add_dependency('rabl', '~> 0.6')

  s.add_development_dependency('yard')
  s.add_development_dependency('rake')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('rspec-rails')

  s.add_development_dependency('capybara', '~> 2.2.1')
  s.add_development_dependency('launchy', '~> 2.4.2')
  s.add_development_dependency('poltergeist', '~>1.5.0')
  s.add_development_dependency('json_spec')
  s.add_development_dependency('factory_girl')
  s.add_development_dependency('database_cleaner')
  s.add_development_dependency('rspec-retry')
end

