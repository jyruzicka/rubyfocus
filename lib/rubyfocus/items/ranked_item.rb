class Rubyfocus::RankedItem < Rubyfocus::NamedItem
  attr_accessor :rank

  # Ranked items also happen to be contained items
  # Container setting is handled by subclasses - tasks and folders
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
    if [String, Integer, Hash, Proc].include?(object.class)
      document.find_all(object).any?{ |o|  ancestry.include?(o) }
    else
      ancestry.include?(object)
    end
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
