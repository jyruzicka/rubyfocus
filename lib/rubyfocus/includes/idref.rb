module Rubyfocus
  module IDRef
    module ClassMethods
      def idref *names
        names.each do |name|
          name_id = "#{name}_id".to_sym
          attr_accessor name_id
          define_method(name) do
            return document && (id_value = send(name_id)) && document.find(id_value)
          end

          define_method("#{name}=") do |o|
            if o.nil?
              self.send("#{name}_id=", nil)
            elsif o.respond_to?(:id)
              self.send("#{name}_id=", o.id)
            else
              raise ArgumentError, "#{self.class}##{name}= called with argument #{o}, which does not respond to :id."
            end
          end
        end
      end
    end

    def self.included(mod)
      mod.extend ClassMethods
    end
  end
end
