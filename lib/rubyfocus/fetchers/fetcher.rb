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

	# This method is called when loading a fetcher from YAML
	def init_with(coder)
		raise RuntimeError, "Method Fetcher#init_with called for abstract class Fetcher"
	end
	
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

	# Returns the ID of head - the latest patch committed to the database.
	def head
		@head ||= (patches.empty? ? base_id : patches.sort.last.to_id)
	end

	# Can you reach head from the given ID?
	def can_reach_head_from?(id)
		patch_array = patches.select{ |p| p.from_ids.include?(id) }
		until patch_array.empty?
			p = patch_array.first
			return true if p.to_id == self.head

			next_patches = patches.select{ |np| np.from_ids.include? p.to_id }
			patch_array = patch_array[1..-1] + next_patches
		end
		return false
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
			np.apply_to(document)
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
		all_possible_patches = self.patches.select{ |patch| patch.can_patch?(document) }
		return all_possible_patches.sort.first
	end


	#---------------------------------------
	# Serialisation info
	def encode_with(coder)
		raise RuntimeError, "Fetcher#encode_with called on abstract class."
	end

	# Remove all cached information
	def reset
		@patches = nil
		@base = nil
	end
end