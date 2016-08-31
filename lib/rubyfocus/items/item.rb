# The Rubyfocus Item represents an item found in an Omnifocus XML file, and thus also
# any Omnifocus entity.
#
# The Rubyfocus Item has a parent "document" as well as a series of properties determined
# by the XML file proper. You can pass an XML document at creation or leave it blank. You
# can always apply XML later using Item#apply_xml or Item#<<
#
# By separating these two methods, we can also patch the object with another XML node, e.g.
# through an update. This is important!
class Rubyfocus::Item
	include Rubyfocus::IDRef
	include Rubyfocus::ConditionalExec
	attr_accessor :id, :added, :modified, :document

	def initialize(document=nil, n=nil)
		case n
		when Nokogiri::XML::Element
			apply_xml(n)
		when Hash
			n.each do |k,v|
				setter = "#{k}="
				send(setter,v) if respond_to?(setter)
			end
		end
		
		document.add_element(self) if document
	end

	def apply_xml(n)
		self.id ||= n["id"] # This should not change once set!
		conditional_set(:added, 		n.at_xpath("xmlns:added"))		{ |e| Time.safely_parse(e) }
		conditional_set(:modified, 	n.at_xpath("xmlns:modified"))	{ |e| Time.safely_parse(e) }
	end
	alias_method :<<, :apply_xml

	#---------------------------------------
	# Inspection method

	def inspect
		msgs = inspect_properties.select{ |sym| self.respond_to?(sym) && !self.send(sym).nil? }
		"#<#{self.class} " + msgs.map{ |e| %|#{e}=#{self.send(e).inspect}| }.join(" ") + ">"
	end

	def to_serial
		inspect_properties.each_with_object({}){ |s,hsh| hsh[s] = self.send(s) }
	end

	#-------------------------------------------------------------------------------
	# Private inspect methods

	private
	def inspect_properties
		%w(id added modified)
	end
end