class Rubyfocus::Folder < Rubyfocus::RankedItem
	include Rubyfocus::Parser
	def self.matches_node?(node)
		return (node.name == "folder")
	end
	
	idref :container

	def apply_xml(n)
		super(n)
		conditional_set(:container_id, n.at_xpath("xmlns:folder")){ |e| e["idref"] }
	end

	private
	def inspect_properties
		super + %w(container_id)
	end
end