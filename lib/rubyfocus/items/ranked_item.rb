class Rubyfocus::RankedItem < Rubyfocus::NamedItem
	attr_accessor :rank

	# Ranked items also happen to be contained items
	idref :container

	# Retrieve a full list of the parents of this item. [0] = immediate parent
	def ancestry
		if container
			[container] + container.ancestry
		else
			[]
		end
	end

	# Is this item contained within another? You may supply an object, string or integer ID, hash of properties,
	# or proc to run on each item.
	def contained_within?(object)
		object = document.find(object) if [String, Fixnum, Hash, Proc].include?(object.class)
		ancestry.include?(object)
	end

	def apply_xml(n)
		super(n)
		conditional_set(:rank, n.at_xpath("xmlns:rank")){ |e| e.inner_html.to_i }
	end

	private
	def inspect_properties
		super + %w(rank)
	end
end