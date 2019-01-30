# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "tunnelss/version"

Gem::Specification.new do |s|
  s.name        = "tunnelss"
  s.version     = Tunnelss::VERSION
  s.authors     = ["rchampourlier"]
  s.email       = ["romain@softr.li"]
  s.homepage    = "https://github.com/rchampourlier/tunnelss"
  s.summary     = %q{Pow + SSL, automated}
  s.description = %q{This tunnels HTTPS to HTTP and configures itself using Pow's config.}

  s.rubyforge_project = "tunnelss"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rr"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-byebug"

  s.add_runtime_dependency "eventmachine", '~> 1.0'
end
