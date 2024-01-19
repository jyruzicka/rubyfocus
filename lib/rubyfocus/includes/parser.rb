module Rubyfocus
  module Parser
    @subclasses = []

    def self.parse(document, node)
      matching_classes = @subclasses.select{ |klass| klass.matches_node?(node) }

      # More than one matches? Take the most specific
      if matching_classes.size > 1
        classes_with_subclasses = matching_classes.select{ |c| matching_classes.any?{ |sc| sc < c } }
        matching_classes = matching_classes - classes_with_subclasses
      end

      case matching_classes.size
      when 0
        nil
      when 1
        return matching_classes.first.new(document, node)
      else
        raise RuntimeError, "Node #{node.inspect} matches more than one Rubyfocus::Item subclass."
      end
    end

    def self.included(mod)
      @subclasses << mod
      mod.extend ClassMethods
    end

    module ClassMethods
      # Filler method
      def matches_node?(node)
        false
      end
    end
  end
end
