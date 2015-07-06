# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = %q{gift-parser}
  s.version = "0.2.1"
  s.authors = ["Stuart Coyle"]
  s.date = %q{2011-06-27}
  s.description = %q{A library for parsing the Moodle GIFT question format.}
  s.email = %q{stuart.coyle@gmail.com}
  # s.extra_rdoc_files = [
  #   "README"
  # ]
  # s.files = [
  #   ".gitignore",
  #    "LICENCE",
  #    "README",
  #    "RakeFile",
  #    "VERSION",
  #    "gift-parser.gemspec",
  #    "github.com",
  #    "lib/gift.rb",
  #    "lib/gift_parser.rb",
  #    "src/gift_parser.treetop",
  #    "test/GIFT-examples.rb",
  #    "test/GIFT-examples.txt",
  #    "test/gift_semantic_test.rb",
  #    "test/gift_syntax_test.rb",
  #    "test/gift_test.rb"
  # ]
  
  s.homepage = %q{http://github.com/stuart/gift-parser}
  s.summary = %q{Moodle GIFT format parser}
  
  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if s.respond_to?(:metadata)
    s.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "treetop", ">= 1.4.5"
  s.add_development_dependency "bundler", "~> 1.10"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec"
  s.add_development_dependency 'pry'
end
