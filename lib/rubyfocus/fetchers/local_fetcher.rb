class Rubyfocus::LocalFetcher < Rubyfocus::Fetcher
	LOCATION = File.join(ENV["HOME"], "/Library/Containers/com.omnigroup.OmniFocus2/Data/Library/Application Support/OmniFocus/OmniFocus.ofocus")

	# Override parent method
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

	def base_id
		base_file = File.basename(Dir[File.join(self.location,"*.zip")].first)
		if base_file =~ /^\d+\=.*\+(.*)\.zip$/
			$1
		else
			raise RuntimeError, "Malformed patch file #{base_file}."
		end
	end

	# Override parent method
	def patches
		@patches ||= Dir[File.join(self.location, "*.zip")][1..-1].map{ |f| Rubyfocus::Patch.new(self, File.basename(f)) }
	end

	def patch(file)
		filename = File.join(self.location, file)
		if File.exists?(filename)
			Zip::File.open(filename){ |z| z.get_entry("contents.xml").get_input_stream.read }
		else
			raise ArgumentError, "Trying to fetch patch #{file}, but file does not exist."
		end
	end

	# Location methods
	def location
		@location || LOCATION
	end

	def location= l
		@location = l
	end
end