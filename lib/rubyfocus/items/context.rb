class Rubyfocus::Context < Rubyfocus::RankedItem
	include Rubyfocus::Parser
	def self.matches_node?(node)
		return (node.name == "context")
	end

	attr_accessor :location

	def apply_xml(n)
		super(n)
		conditional_set(:container_id,n.at_xpath("xmlns:context")) { |e| e["idref"] }
		conditional_set(:location, 		n.at_xpath("xmlns:location")){ |e| Rubyfocus::Location.new(e) }
	end
end