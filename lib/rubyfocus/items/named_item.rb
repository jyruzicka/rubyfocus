class Rubyfocus::NamedItem < Rubyfocus::Item
	attr_accessor :name

	def apply_xml(n)
		super(n)
		conditional_set(:name, n.at_xpath("xmlns:name"), &:inner_html)
	end

	def to_s
		@name
	end

	private
	def inspect_properties
		super + %w(name)
	end
end