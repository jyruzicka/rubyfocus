# This fetcher fetches data from the OmniSyncServer.
# NOTE: This does *not* register a client with the OmniSyncServer. As such, if you don't
# sync with the database regularly, you will likely lose track of the head and have to re-sync.
class Rubyfocus::OSSFetcher < Rubyfocus::Fetcher
	# Used to log in to the Omni Sync Server. Also determines the URL of your file
	attr_accessor :username
	attr_accessor :password

	# The engine used to fetch data. Defaults to HTTParty
	attr_accessor :fetcher

	#---------------------------------------
	# Parent method overrides

	# Initialise with username and password
	def initialize(u,p)
		@username = u
		@password = p
		@fetcher = HTTParty
	end

	# Init from yaml
	def init_with(coder)
		@username = coder["username"]
		@password = coder["password"]
		@fetcher = HTTParty
	end

	# Fetches the contents of the base file
	def base
		@base ||= if self.patches.size > 0
			fetch_file(self.patches.first.file)
		else
			raise Rubyfocus::OSSFetcherError, "Looking for zip files at #{url}: none found."
		end
	end

	# Fetches the ID Of the base file
	def base_id
		if self.patches.size > 0
			base_file = self.patches.first
			if base_file.file =~ /^\d+\=.*\+(.*)\.zip$/
				$1
			else
				raise Rubyfocus::OSSFetcherError, "Malformed patch file #{base_file}."
			end
		else
			raise Rubyfocus::OSSFetcherError, "Looking for zip files at #{url}: none found."
		end
	end

	# Fetches a list of all files contained within the database
	def files
		@files ||= begin
			response = self.fetcher.get(url, digest_auth: auth).body
			# Text is in first table, let's assume
			table = response[/<table>(.*?)<\/table>/m,1]
			if table
				table.scan(/<a href="([^"]+)"/).flatten
			else
				[]
			end
		end
	end

	# Fetches a list of every patch file
	def patches
		@patches ||= files.select{ |f| f.end_with?(".zip") }.map{ |u| Rubyfocus::Patch.new(self,u) }
	end

	# Fetches the contents of a given patch file
	def patch(file)
		fetch_file(file)
	end

	# Is this encrypted?
	def encrypted?
		files.find{ |f| File.basename(f) == "encrypted" }
	end

	# Save to disk
	def encode_with(coder)
		coder.map = {
			"username" => @username,
			"password" => @password
		}
	end

	#---------------------------------------
	# Private aux methods
	private
	def auth
		{username: @username, password: @password}
	end

	def url
		"https://sync.omnigroup.com/#{@username}/OmniFocus.ofocus"
	end

	def fetch_file(f)
		fq_zipfile = File.join(url,f)
		data = self.fetcher.get(fq_zipfile, digest_auth: auth).body
		io = StringIO.new(data)
		Zip::InputStream.open(io) do |io|
			while (entry = io.get_next_entry)
				return io.read if entry.name == "contents.xml"
			end
			raise Rubyfocus::OSSFetcherError, "Malformed OmniFocus zip file #{fq_zipfile}."
		end
	end
end
