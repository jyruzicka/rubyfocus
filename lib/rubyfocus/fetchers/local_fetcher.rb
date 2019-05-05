class Rubyfocus::LocalFetcher < Rubyfocus::Fetcher

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
			zip_file = Dir[File.join(self.location,"*.zip")].sort.first
			if zip_file
				Zip::File.open(zip_file){ |z| z.get_entry("contents.xml").get_input_stream.read }
			else
				raise RuntimeError, "Rubyfocus::LocalFetcher looking for zip files at #{self.location}: none found."
			end
		end
	end

	# Fetches the ID Of the base file
	def base_id
		base_file = File.basename(sorted_files.first)
		if base_file =~ /^\d+\=.*\+(.*)\.zip$/
			$1
		else
			raise RuntimeError, "Malformed patch file #{base_file}."
		end
	end

	# Fetches a list of every patch file
	def patches
		@patches ||= sorted_files[1..-1].map{ |f| Rubyfocus::Patch.new(self, File.basename(f)) }
	end

	# Fetch a sorted list of files from this directory
	private def sorted_files
		@sorted_files ||= Dir[File.join(self.location, "*.zip")].sort
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

	# Is this fetcher fetching encrypted data?
	def encrypted?
		File.exists?(File.join(self.location, "encrypted"))
	end

	#---------------------------------------
	# Location file setters and getters

	# Where do we expect OS X to store containers?
	def container_location
		@container_location ||= File.join(ENV["HOME"], "Library/Containers/")
	end

	attr_writer :container_location

	# Default (non app-store) file location. Will look for "com.omnigroup.Omnifocus###"
	# (where ### is a number) and pick the most recent.
	#
	# If it cannot find any directories matching this pattern, will return ""
	# (empty string). Note that File.exists?("") returns `false`.
	def default_location
		if @default_location.nil?
			omnifocus_directories = Dir[File.join(container_location, "com.omnigroup.OmniFocus*")]

			default_omnifocus_directories = omnifocus_directories.select{ |path|
				File.basename(path) =~ /com\.omnigroup\.OmniFocus\d+$/
			}

			if (default_omnifocus_directories.size == 0)
				# If none match the regexp, we return ""
				@default_location = ""
			else
				# Otherwise, match highest
				last_omnifocus_directory = default_omnifocus_directories.sort().last()
				
				@default_location = File.join(
					last_omnifocus_directory,
					"Data/Library/Application Support/OmniFocus/OmniFocus.ofocus"
				)
			end
		end

		return @default_location
	end

	# App store file location. Will look for "com.omnigroup.Omnifocus###.MacAppStore"
	# (where ### is a number) and pick the most recent.
	#
	# If it cannot find any directories matching this pattern, will return ""
	# (empty string). Note that File.exists?("") returns `false`.
	def appstore_location
		if @appstore_location.nil?
			omnifocus_directories = Dir[File.join(container_location, "com.omnigroup.OmniFocus*")]

			appstore_omnifocus_directories = omnifocus_directories.select{ |path|
				File.basename(path) =~ /com\.omnigroup\.OmniFocus\d+\.MacAppStore$/
			}

			if (appstore_omnifocus_directories.size == 0)
				# If none match the regexp, we return ""
				@appstore_location = ""
			else
				# Otherwise, match highest
				last_omnifocus_directory = appstore_omnifocus_directories.sort().last()
				
				@appstore_location = File.join(
					last_omnifocus_directory,
					"Data/Library/Application Support/OmniFocus/OmniFocus.ofocus"
				)
			end
		end

		return @appstore_location
	end

	# Determine location based on assigned and default values. Returns +nil+
	# if no assigned location and default locations don't exist.
	def location
		if @location
			@location
		elsif File.exists?(default_location)
			default_location
		elsif File.exists?(appstore_location)
			appstore_location
		else
			nil
		end
	end

	def location= l
		@location = l
	end
end