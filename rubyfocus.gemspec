# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rubyfocus"
  s.version = File.read("version.txt")
  s.licenses = ["MIT"]
  
  s.summary = "Pure ruby bridge to OmniFocus."
  s.description = "Use this gem to talk to OmniFocus. Extracts projects, contexts, and tasks from local or remote OmniFocus databases."
  
  s.author = "Jan-Yves Ruzicka"
  s.email = "jan@1klb.com"
  s.homepage = "http://1klb.com/projects/rubyfocus/"
  
  s.files = File.read("Manifest").split("\n").select{ |l| !l.start_with?("#") && l != ""}
  s.require_paths << "lib"
  s.extra_rdoc_files = ["README.md"]

  # Add runtime dependencies here
  s.add_runtime_dependency "nokogiri", "~> 1.8", ">= 1.8.5"
  s.add_runtime_dependency "rubyzip", "~> 1.2", ">= 1.2.2"
  s.add_runtime_dependency "httparty", "~> 0.13", ">= 0.13.7"
end
