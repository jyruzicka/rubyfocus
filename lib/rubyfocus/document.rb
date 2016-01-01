# The Document is how rubyfocus stores an OmniFocus document, both locally and otherwise.
# A Document contains a number of arrays of contexts, settings, folders, projects, and tasks,
# and is also able to keep track of what patch it's up to, for updating.
#
# You can initialize a document through +Document.new(doc)+, where +doc+ is either an XML string, or
# a Nokogiri XML document (or +nil+). Alternatively, you can initialize through +Document.from_file(file)+,
# which reads the file and parses it as XML
#
# You add XML to the document by running +Documet::apply_xml(doc)+, which takes all children of the root
# XML node, tries to turn each child into a relevant object, and adds it to the document. This is done using
# the private +ivar_for+ method, as well as +add_element(e)+, which you can use to add individual objects.
class Rubyfocus::Document
	include Rubyfocus::Searchable
	# A number of arrays into which elements may fit
	attr_reader :contexts, :settings, :folders, :projects, :tasks

	# This is the identifier of the current patch level. This also determines
	# which patches can be applied to the current document.
	attr_accessor :patch_id

	# This is the fetcher object, used to fetch new data
	attr_accessor :fetcher

	# Does this document allow us to add more than one element with the same ID? 
	# Defaults to false
	attr_accessor :allow_duplicate_ids

	# Initalise with one of:
	# * a Nokogiri document
	# * a string
	# * a fetcher subclass
	def initialize(doc=nil)
		@allow_duplicate_ids = false
		%w(contexts settings projects folders tasks).each{ |s| instance_variable_set("@#{s}", Rubyfocus::SearchableArray.new) }

		if doc
			if doc.is_a?(String)
				apply_xml(Nokogiri::XML(doc))
			elsif doc.is_a?(Nokogiri::XML)
				apply_xml(doc)
			elsif doc.kind_of?(Rubyfocus::Fetcher)
				self.fetcher = doc
				base = Nokogiri::XML(doc.base)
				self.apply_xml(base)
				self.patch_id = doc.base_id
			end
		end
	end

	#...or from file! If you provide it with an XML file, it'll load up without a fetcher.
	def self.from_xml(file)
		new(File.read(file))
	end

	# Initialize from the local repo
	def self.from_local
		new(Rubyfocus::LocalFetcher.new)
	end

	# Initialize with a URL, for remote fetching.
	# Not implemented yet
	def self.from_url(url)
		raise RuntimeError, "Rubyfocus::Document.from_url not yet implemented."
		# new(Rubyfocus::RemoteFetcher.new(url))
	end

	# Load from a a hash
	def self.load_from_file(file_location)
		d = YAML::load_file(file_location)
		d.fetcher.reset
		d
	end

	#---------------------------------------
	# Use the linked fetcher to update the document
	def update
		if fetcher
			fetcher.update_full(self)
		else
			raise RuntimeError, "Tried to update a document with no fetcher."
		end
	end

	#-------------------------------------------------------------------------------
	# Apply XML!
	def apply_xml(doc)
		doc.root.children.select{ |e| !e.text? }.each do |node|
			elem = Rubyfocus::Parser.parse(self, node)
		end
	end

	# Given an object, work out the correct instance variable for it to go into
	def ivar_for(obj)
		{
			Rubyfocus::Project => @projects,
			Rubyfocus::Context => @contexts,
			Rubyfocus::Task => @tasks,
			Rubyfocus::Folder => @folders,
			Rubyfocus::Setting => @settings
		}[obj.class]
	end
	private :ivar_for

	# Add an element. Element should be a Project, Task, Context, Folder, or Setting
	# We assume whoever does this will set document appropriately on the element
	def add_element(e)
		if !allow_duplicate_ids && has_id?(e.id)
			raise Rubyfocus::DocumentElementException, "Element with ID #{e.id} already exists within this document."
		else
			dest = ivar_for(e)
			if dest
				dest << e
			else
				raise ArgumentError, "You passed a #{e.class} to Document#add_element - I don't know what to do with this."
			end
		end
	end

	# Remove an element from the document.
	# We assume whoever does this is smart enough to also set the element's #document value
	# to nil
	def remove_element(e)
		e = self[e] if e.is_a?(String)
		return if e.nil?

		dest = ivar_for(e)
		if dest
			dest.delete(e)
		else
			raise ArgumentError, "You passed a #{e.class} to Document#remove_element - I don't know what to do with this."	
		end
	end

	#-------------------------------------------------------------------------------
	# Searchable stuff
	def elements
		@tasks + @projects + @contexts + @folders + @settings
	end

	# For Searchable include
	alias_method :array, :elements


	#-------------------------------------------------------------------------------
	# Find elements from id
	def [] search_id
		self.elements.find{ |elem| elem.id == search_id }
	end

	# Check if the document has an element of a given ID
	def has_id?(id)
		self.elements.any?{ |e| e.id == id }
	end

	#---------------------------------------
	# YAML export

	def save(file)
		File.open(file, "w"){ |io| io.puts YAML::dump(self) }
	end
end

#-------------------------------------------------------------------------------
# Exceptions
class Rubyfocus::DocumentElementException < Exception; end