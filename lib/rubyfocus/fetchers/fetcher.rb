# The Fetcher class is a class that fetches data from a place - generally either a file location or a web address.
# The Fetcher is initialized with (by default) no options, although subclasses of Fetcher may change this.
#
# Each Fetcher has two important methods:
#
# * Fetcher#base returns the text of the main xml file, upon which all patch are applied.
# * Fetcher#patch returns the text of each update file as an array.
#
# You may also use the Fetcher#each_patch to iterate through all updates.
#
# To patch a document, simply call +Fetcher#update_full()+, passing it the document to be patched.
# +Document#update+ will automatically send the fetcher the document.

class Rubyfocus::Fetcher
	# Returns the content of the base file
	def base
		raise RuntimeError, "Method Fetcher#base called for abstract class Fetcher."
	end

	# Returns the id of the base
	def base_id
		raise RuntimeError, "Method Fetcher#base_id called for abstract class Fetcher."
	end

	# Returns an array of patch paths - either files or urls
	def patches
		raise RuntimeError, "Method Fetcher#patches called for abstract class Fetcher."
	end

	# Returns the contents of a given patch
	def patch(filename)
		raise RuntimeError, "Method Fetcher#patch called for abstract class Fetcher."
	end

	#---------------------------------------
	# Patching methods

	# Update the document as far as we can
	def update_full(document)
		update_once(document) while can_patch?(document)
	end

	# Update the document one step. Raises an error if the document cannot be updated.
	def update_once(document)
		np = self.next_patch(document)
		if np
			apply_patch(np, document)
		else
			raise RuntimeError, "Patcher#update_once called, but I can't find a patch to apply!"
		end
	end

	# Can we patch this document? You should call this before update_onceing
	def can_patch?(document)
		!next_patch(document).nil?
	end

	# Collect the next patch to the document. If more than one patch can be applied,
	# apply the latest one.
	def next_patch(document)
		all_possible_patches = self.patches.select{ |patch| patch.from_ids.include?(document.patch_id) } # TODO spec new from_ids code
		return all_possible_patches.sort_by(&:time).last
	end

	# Actually apply a patch to the document.
	# Raises a RuntimeError if you try to apply an illegal patch (i.e. from_id
	# and document.patch_id don't match).
	def apply_patch(patch, document)
		if !patch.from_ids.include?(document.patch_id)
			raise RuntimeError, "Patch ID mismatch (patch from_ids: [#{patch.from_ids.join(", ")}], document.patch_id: #{document.patch_id}"
		end

		# Go through, apply updates, creates, and deletes

		# Updates modify elements
		patch.update.each do |node|
			elem = document[node["id"]]
			elem.apply_xml(node) if elem
		end

		# Deletes remove elements
		patch.delete.each do |node|
			document.remove_element(node["id"])
		end

		# Creates make new elements
		patch.create.each do |node|
			element = Rubyfocus::Parser.parse(nil, node)
			if element
				document.add_element element
			else
				raise RuntimeError, "Encountered unparsable XML during patch reading: #{node}."
			end
		end

		# Modify current patch_id to show new value
		document.patch_id = patch.to_id
	end

	# Remove all cached information
	def reset
		@patches = nil
		@base = nil
	end
end