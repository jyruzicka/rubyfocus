class Rubyfocus::Context < Rubyfocus::RankedItem
  include Rubyfocus::Parser
  def self.matches_node?(node)
    return (node.name == "context")
  end

  attr_accessor :location

  def apply_xml(n)
    super(n)
    conditional_set(:container_id, n.at_xpath("xmlns:context")) { |e| e["idref"] }
    conditional_set(:location, n.at_xpath("xmlns:location")) { |e| Rubyfocus::Location.new(e) }
  end

  def child_contexts
    document.contexts.find_all { |context| context.ancestry.first == self }
  end

  def with_descendant_contexts
    descendant_contexts.unshift(self)
  end

  def child_tasks
    document.tasks.select(context_id: self.id)
  end

  def descendant_tasks
    with_descendant_contexts.flat_map { |context| document.tasks.select(context_id: context.id) }
  end

  private

  def descendant_contexts
    document.contexts.find_all { |context| context.contained_within?(self) }
  end
end
