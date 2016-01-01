# The patch class represents a text-file patch, storing update, delete, and creation operations.
# It should also be able to apply itself to an existing document.
class Rubyfocus::Patch
	# The fetcher this patch belongs to. We mainly use this to work out how to fetch content for the patch proper
	attr_accessor :fetcher

	# Operations to be performed on a document
	attr_accessor :update, :delete, :create

	# The file the patch loads from
	attr_accessor :file

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

				ids 					= $2.split("+")
				self.to_id 		= ids.pop
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
		# Updates modify elements
		self.update.each{ |node| update_node(document, node) }
		
		# Deletes remove elements
		self.delete.each{ |node| document.remove_element(node["id"]) }

		# Creates make new elements
		self.create.each do |node|
			# Sometimes we get aberrant create calls when what we actually want is an update.
			# We can tell this because the IDs will duplicate. Here we deal with that appropriately.
			if document.has_id?(node[:id])
				update_node(document, node)
			else
				raise(RuntimeError, "Encountered unparsable XML during patch reading: #{node}.") if Rubyfocus::Parser.parse(document, node).nil?
			end
		end

		# Modify current patch_id to show new value
		document.patch_id = self.to_id
	end

	# Atomic node update code
	def update_node(document, node)
		elem = document[node["id"]]

		# Tasks can become projects and v.v.: check this.
		if [Rubyfocus::Task, Rubyfocus::Project].include?(elem.class)
			should_be_project = (node.at_xpath("xmlns:project") != nil)
			if (elem.class == Rubyfocus::Project) && !should_be_project
				elem.document = nil # Remove this from current document
				elem = elem.to_task # Convert to task
				elem.document = document # Insert again!
			elsif (elem.class == Rubyfocus::Task) && should_be_project
				elem.document = nil # Remove this from current document
				elem = elem.to_project # Convert to task
				elem.document = document # Insert again!
			end
		end

		elem.apply_xml(node) if elem
	end

	# String representation
	def to_s
		if from_ids.size == 1
			"(#{from_ids.first} -> #{to_id})"
		else
			"([#{from_ids.join(", ")}] -> #{to_id})"
		end
	end
end