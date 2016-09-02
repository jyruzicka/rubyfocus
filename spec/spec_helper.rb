require "ostruct"
require File.join(__dir__, "../lib/rubyfocus")

SPEC_ROOT = __dir__

def lib(s)
	require_relative "../lib/#{s}"
end

def file(fname)
	File.join(__dir__, "files", fname)
end

def xml(name)
	file = "#{__dir__}/xml/#{name}.xml"
	if File.exists?(file)
		prefix = %|<?xml version="1.0" encoding="utf-8" standalone="no"?><omnifocus xmlns="http://www.omnigroup.com/namespace/OmniFocus/v2">|
		suffix = "</omnifocus>"
		data = prefix + File.read(file) + suffix
		return Nokogiri::XML(data).at_xpath("/xmlns:omnifocus").elements.first
	else
		raise ArgumentError, "XML file \"#{name}\" not recognised."
	end
end