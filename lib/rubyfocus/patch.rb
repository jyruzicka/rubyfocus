# The patch class represents a text-file patch, storing update, delete, and creation operations.
# It should also be able to apply itself to an existing document.
class Rubyfocus::Patch
  include Comparable
  # The fetcher this patch belongs to. We mainly use this to work out how to fetch content for the patch proper
  attr_accessor :fetcher

  # Operations to be performed on a document
  attr_accessor :update, :delete, :create

  # The file the patch loads from
  attr_accessor :file

  # What version of patch file is this? Determined from XML file
  attr_accessor :version

  # These record the transformation in terms of patch ID values.
  attr_accessor :from_ids, :to_id

  # The time the file was submitted
  attr_accessor :time

  # By default we initialize patches from a file. To initialize from a string, use the .from_string method.
  # This class will lazily load data from the file proper
  def initialize(fetcher=nil, file=nil)
    @fetcher = fetcher
    @file = file
    @update = []
    @create = []
    @delete = []

    if file
      if File.basename(file) =~ /^(\d+)=(.*)\./
        time_string = $1
        self.time = if (time_string == "00000000000000")
          Time.at(0)
        else
          Time.parse(time_string)
        end

        ids           = $2.split("+")
        self.to_id     = ids.pop
        self.from_ids = ids
      else
        raise ArgumentError, "Constructed patch from a malformed patch file: #{file}."
      end
    end
  end

  # Load from a string.
  def self.from_string(fetcher, str)
    n = new(fetcher)
    n.load_data(str)
    n
  end

  # Loads data from the file. Optional argument +str+ if you want to supply your own data,
  # otherwise will load file data
  def load_data(str=nil)
    return if @data_loaded
    @data_loaded = true

    str ||= fetcher.patch(self.file)
    doc = Nokogiri::XML(str)

    # Root should be an <omnifocus> and have an XMLNS
    # XMLNS should be one of:
    # * http://www.omnigroup.com/namespace/OmniFocus/v1
    # * http://www.omnigroup.com/namespace/OmniFocus/v2
    omnifocus = doc.root
    if omnifocus.name == "omnifocus"
      xmlns = omnifocus.namespace && omnifocus.namespace.href
      case xmlns
      when "http://www.omnigroup.com/namespace/OmniFocus/v1"
        self.version = 1
      when "http://www.omnigroup.com/namespace/OmniFocus/v2"
        self.version = 2
      else
        raise ArgumentError, "Unrecognised namespace #{xmlns.inspect} for Omnifocus patch file."
      end
    else
      raise ArgumentError, "Root element should be <omnifocus>, instead was <#{omnifocus.name}>."
    end

    doc.root.children.select{ |n| !n.text?}.each do |child|
      case child["op"]
      when "update"
        @update << child
      when "delete"
        @delete << child
      when "reference" # Ignore!
      when nil
        @create << child
      else
        raise RuntimeError, "Rubyfocus::Patch encountered unknown operation type #{child["op"]}."
      end
    end
  end

  # Update, delete and create methods
  def update; load_data; @update; end
  def delete; load_data; @delete; end
  def create; load_data; @create; end

  # Can we apply this patch to a given document?
  def can_patch?(document)
    self.from_ids.include?(document.patch_id)
  end

  # Apply this patch to a document. Check to make sure ids match
  def apply_to(document)
    if can_patch?(document)
      apply_to!(document)
    else
      raise RuntimeError, "Patch ID mismatch (patch from_ids: [#{self.from_ids.join(", ")}], document.patch_id: #{document.patch_id}"
    end
  end

  # Apply this patch to a document.
  def apply_to!(document)
    load_data

    # Updates depend on version!
    if version == 1
      #V1 updates overwrite elements
      self.update.each{ |node| document.overwrite_element(node) }
    elsif version == 2
      #V2 updates actually update elements
      self.update.each{ |node| document.update_element(node) }
    else
      raise RuntimeError, "Cannot run updates using Version #{version.inspect} OF patches!"
    end

    # Deletes remove elements
    self.delete.each{ |node| document.remove_element(node["id"]) }

    # Creates make new elements
    self.create.each{ |node| document.update_element(node) }

    # Modify current patch_id to show new value
    document.patch_id = self.to_id
  end

  # String representation
  def to_s
    if from_ids.size == 1
      "(#{from_ids.first} -> #{to_id})"
    else
      "([#{from_ids.join(", ")}] -> #{to_id})"
    end
  end

  def <=> o
    if self.time.nil?
      if o.time.nil?
        0
      else
        -1
      end
    else
      if o.time.nil?
        1
      else
        self.time <=> o.time
      end
    end
  end
end
