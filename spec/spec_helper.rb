require "ostruct"
require File.join(__dir__, "../lib/rubyfocus")

SPEC_ROOT = __dir__

def lib(s)
	require_relative "../lib/#{s}"
end

def file(fname)
	File.join(__dir__, "files", fname)
end

# Super-powered XML method can produce XML from a file, a string, or a block
def xml(file:nil, string:nil, &block)
	xml_str = if file
		path = "#{__dir__}/xml/#{file}.xml"
		if File.exist?(path)
			File.read(path)
		else
			raise ArgumentError, "XML file \"#{name}\" not recognised."
		end
	elsif string
		string
	elsif block
		XMLMaker.make(&block)
	else
		raise ArgumentError, "No argument supplied to xml()."
	end

	prefix = %|<?xml version="1.0" encoding="utf-8" standalone="no"?><omnifocus xmlns="http://www.omnigroup.com/namespace/OmniFocus/v2">|
	suffix = "</omnifocus>"
	xml_str = prefix + xml_str + suffix
	return Nokogiri::XML(xml_str).at_xpath("/xmlns:omnifocus").elements.first
end

#---------------------------------------
# XML maker
module XMLMaker
	def self.make(&blck)
		instance_exec(&blck)
	end

	def self.tag(name, opts={}, &blck)
		opts = opts.map{ |k,v| %| #{k}="#{v.gsub('"','\"')}"| }.join("")
		if blck
			"<#{name}#{opts}>" + instance_exec(&blck) + "</#{name}>"
		else
			"<#{name}#{opts} />"
		end
	end
end

# Will only puts if $debug is set
def verbose(*str)
	puts(*str) if $verbose
end

def verbosely &blck
	$verbose = true
	blck[]
	$verbose = false
end

$verbose = false

# Build a tiny webpage out of files
def webpage(*files)
	"<html><table>" + files.map{ |f| %|<tr><td><a href="#{f}">filename</a></td></tr>|}.join("") + "</table></html>"
end
