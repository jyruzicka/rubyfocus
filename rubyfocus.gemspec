# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rubyfocus"
  s.version = File.read('version.txt')
  s.licenses = ["MIT"]
  
  s.summary = "Gem summary here."
  s.description = "Gem description here."
  
  s.author = 'Jan-Yves Ruzicka'
  s.email = 'janyves.ruzicka@gmail.com'
  s.homepage = 'https://github.com/jyruzicka/rubyfocus'
  
  s.files = File.read('Manifest').split("\n").select{ |l| !l.start_with?('#') && l != ''}
  s.require_paths << 'lib'
  s.extra_rdoc_files = ['README.md']

  # Add runtime dependencies here
  s.add_runtime_dependency 'nokogiri', '~> 1.6', ">= 1.6.6"
  s.add_runtime_dependency 'rubyzip', '~> 1.1', ">= 1.1.7"
end
