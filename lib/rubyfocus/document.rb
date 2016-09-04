# The Document is how rubyfocus stores an OmniFocus document, both locally and otherwise.
# A Document contains a number of arrays of contexts, settings, folders, projects, and tasks,
# and is also able to keep track of what patch it's up to, for updating.
#
# You can initialize a document through +Document.new(doc)+, where +doc+ is either an XML string, or
# a Nokogiri XML document (or +nil+). Alternatively, you can initialize through +Document.from_file(file)+,
# which reads the file and parses it as XML
#
# You add XML to the document by running +Document::apply_xml(doc)+, which takes all children of the root
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

	# Initalise with one of:
	# * a Nokogiri document
	# * a string
	# * a fetcher subclass
	def initialize(doc=nil)
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
	# Not implemented yet TODO implement
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

	# Add an element. Element should be a Project, Task, Context, Folder, or Setting.
	# If overwrite set to false and ID already occurs in the document, throw an error.
	# If ID is nil, throw an error.
	def add_element(e, overwrite:false)
		# Error check
		raise(Rubyfocus::DocumentElementException, "Adding element to document, but it has no ID.") if e.id.nil?
		raise(Rubyfocus::DocumentElementException, "Adding element to document, but element with this ID already exists.") if !overwrite && has_id?(e.id)

		# Otherwise, full steam ahead
		e.document = self

		if (dupe_element = self[e.id]) && overwrite
			remove_element(dupe_element)
		end

		# Add to the correct array
		dest = ivar_for(e)
		if dest
			dest << e
		else
			raise ArgumentError, "You passed a #{e.class} to Document#add_element - I don't know what to do with this."
		end
	end

	# Remove an element from the document.
	def remove_element(e)
		e = self[e] if e.is_a?(String)
		return if e.nil?

		e.document = nil

		dest = ivar_for(e)
		if dest
			dest.delete(e)
		else
			raise ArgumentError, "You passed a #{e.class} to Document#remove_element - I don't know what to do with this."	
		end
	end

	# Update an element in-place by applying xml. This method also takes into account:
	# * new nodes (i.e. silently creates if required)
	# * tasks upgraded to projects
	# * projects downgraded to tasks
	# Note that unlike add_element, this takes pure XML
	def update_element(node)
		element = self[node["id"]]

		# Does element already exist?
		if element
			# Quick check: is it a task being upgraded to a project?
			if element.class == Rubyfocus::Task && Rubyfocus::Project.matches_node?(node)
				# Upgrade
				new_node = element.to_project
				new_node.apply_xml(node)
				add_element(new_node, overwrite:true)
			# or is the project being downgraded to a task?
			elsif element.class == Rubyfocus::Project && !Rubyfocus::Project.matches_node?(node)
				# Downgrade
				new_node = element.to_task
				new_node.apply_xml(node)
				add_element(new_node, overwrite:true)
			else
				# Update in-place
				element.apply_xml(node)
			end
		else
			# Create a new node and add it
			Rubyfocus::Parser.parse(self,node)
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