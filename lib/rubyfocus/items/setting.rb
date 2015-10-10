class Rubyfocus::Setting < Rubyfocus::Item
	include Rubyfocus::Parser
	def self.matches_node?(node)
		return (node.name == "xmlns:plist")
	end
	
	attr_accessor :value

	def apply_xml(n)
		super(n)
		conditional_set(:value, n.at_xpath("xmlns:plist").children.first){ |e| Rubyfocus::XMLTranslator.parse(e) }
	end

	def inspect
		form_inspector(:id, :name, :value, :added, :modified)
	end
end