class Rubyfocus::LocalFetcher < Rubyfocus::Fetcher
	# This is where the files are usually stored
	LOCATION = File.join(ENV["HOME"], "/Library/Containers/com.omnigroup.OmniFocus2/Data/Library/Application Support/OmniFocus/OmniFocus.ofocus")

	#---------------------------------------
	# Parent method overrides

	# Init from yaml
	def init_with(coder)
		if coder["location"]
			@location = coder["location"]
		end
	end

	# Fetches the contents of the base file
	def base
		@base ||= begin
			zip_file = Dir[File.join(self.location,"*.zip")].first
			if zip_file
				Zip::File.open(zip_file){ |z| z.get_entry("contents.xml").get_input_stream.read }
			else
				raise RuntimeError, "Rubyfocs::LocalFetcher looking for zip files at #{self.location}: none found."
			end
		end
	end

	# Fetches the ID Of the base file
	def base_id
		base_file = File.basename(Dir[File.join(self.location,"*.zip")].first)
		if base_file =~ /^\d+\=.*\+(.*)\.zip$/
			$1
		else
			raise RuntimeError, "Malformed patch file #{base_file}."
		end
	end

	# Fetches a list of every patch file
	def patches
		@patches ||= Dir[File.join(self.location, "*.zip")][1..-1].map{ |f| Rubyfocus::Patch.new(self, File.basename(f)) }
	end

	# Fetches the contents of a given patch file
	def patch(file)
		filename = File.join(self.location, file)
		if File.exists?(filename)
			Zip::File.open(filename){ |z| z.get_entry("contents.xml").get_input_stream.read }
		else
			raise ArgumentError, "Trying to fetch patch #{file}, but file does not exist."
		end
	end

	# Save to disk
	def encode_with(coder)
		coder.map = {"location" => @location}
	end

	#---------------------------------------
	# Location file setters and getters
	def location
		@location || LOCATION
	end

	def location= l
		@location = l
	end
end