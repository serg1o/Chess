Gem::Specification.new do |gem|
	gem.name = "chess"
	gem.files = Dir["lib/**/*.rb"]
	gem.version = "0.0.0"
	gem.authors = "Sérgio Ribeiro", "Zachary Perlmutter"
	gem.email = "sergiomsr@sapo.pt", "zrp200@gmail.com"
	gem.required_ruby_version = "> 1.8.7"
	gem.test_files = Dir["spec/**/*_spec.rb"]
	gem.executables << "chess"
end
