Gem::Specification.new do |gem|
	gem.name = "chess"
	gem.files = Dir["lib/**/*.rb"]
	gem.version = "0.0.0"
	gem.required_ruby_version = "> 1.8.7"
	gem.test_files = Dir["spec/**/*_spec.rb"]
	gem.executables << "chess"
end
