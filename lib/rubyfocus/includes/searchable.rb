module Rubyfocus
  # The Searchable module allows you to easily search arrays of items by
  # effectively supplying find and select methods. Passing a hash to either
  # of these methods allows you to search by given properties - for example:
  #
  #   data_store.find(name: "Foobar")
  #
  # Is basically the same as:
  #
  #   data_store.find{ |o| o.name == "Foobard" }
  #
  # If you pass +find+ or +select+ a String or Integer, it will look for objects
  # whose +id+ equals this value.
  #
  # You should ensure that your class' +array+ method is overwritten to point
  # to the appriopriate array.
  module Searchable
    # This method will return only the *first* object that matches the given
    # criteria, or +nil+ if no object is found.
    def find(arg=nil, &blck)
      fs_block = find_select_block(arg) || blck
      if fs_block
        return array.find(&fs_block)
      else
        raise ArgumentError, "ItemArray#find called with #{arg.class} argument."
      end
    end

    # This method will return an array of all objects that match the given
    # criteria, or +[]+ if no object is found.
    def select(arg=nil, &blck)
      fs_block = find_select_block(arg) || blck
      if fs_block
        return array.select(&fs_block)
      else
        raise ArgumentError, "ItemArray#select called with #{arg.class} argument."
      end
    end
    alias_method :find_all, :select

    # This method should be overriden
    def array
      raise RuntimeError, "Method #{self.class}#array has not been implemented!"
    end

    private
    # This method determines the correct block to use in find or select operations
    def find_select_block(arg)
      case arg
      when Integer # ID
        string_id = arg.to_s
        Proc.new{ |item| item.id == string_id }
      when String
        Proc.new{ |item| item.id == arg }
      when Hash
        Proc.new{ |item| arg.all?{ |k,v| item.send(k) == v } }
      else
        nil
      end
    end
  end


  # A sample class, SearchableArray, is basically a wrapper around a standard array
  class SearchableArray
    include Searchable
    attr_reader :array

    # Takes the same arguments as the array it wraps
    def initialize(*args, &blck)
      @array = Array.new(*args, &blck)
    end

    # In all other respects, it's an array - handily governed by this method
    def method_missing meth, *args, &blck
      if @array.respond_to?(meth)
        @array.send(meth, *args, &blck)
      else
        super(meth, *args, &blck)
      end
    end
  end
end
