module Rubyfocus::XMLTranslator
  class << self
    VALID_NODE_NAMES = %w(string true false integer array)

    # Actual parsing method
    def parse(node)
      method_name = node.name
      if VALID_NODE_NAMES.include?(method_name)
        self.send(method_name, node)
      else
        raise RuntimeError, "Does not recognise node type: #{method_name}."
      end
    end

    # Individual parsing methods
    def string(node)
      node.inner_html
    end

    def true(node)
      true
    end

    def false(node)
      false
    end

    def integer(node)
      node.inner_html.to_i
    end

    def array(node)
      node.children.map{ |child| parse(child) }
    end
  end
end
