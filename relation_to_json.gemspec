# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'relation_to_json/version'

Gem::Specification.new do |spec|
  spec.name          = "relation_to_json"
  spec.version       = RelationToJSON::VERSION
  spec.authors       = ["Derek Yu"]
  spec.email         = ["derek-nis@hotmail.com"]

  spec.summary       = %q{RelationToJSON converts a Rails ActiveRecord Relation to JSON, provided a schema}
  spec.description   = <<~DESC
                        RelationToJSON takes in a schema of attributes and associations
                        together with an ActiveRecord::Relation object and produces an array of nested hashes
                        corresponding to a JSON representation of each record.
                        DESC

  spec.homepage      = "https://github.com/Derekyu177/relation_to_json"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.2"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  spec.add_runtime_dependency "activesupport", "> 5.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "activerecord", "~> 7.0.0"
  spec.add_development_dependency "sqlite3", "~> 1.4.2"
end
