class Rubyfocus::RankedItem < Rubyfocus::NamedItem
	attr_accessor :rank

	def apply_xml(n)
		super(n)
		conditional_set(:rank, n.at_xpath("xmlns:rank")){ |e| e.inner_html.to_i }
	end

	private
	def inspect_properties
		super + %w(rank)
	end
end