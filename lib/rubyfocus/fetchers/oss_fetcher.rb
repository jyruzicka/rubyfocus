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
	end

	# Fetches the contents of the base file
	def base
		@base ||= if self.patches.size > 0
			fetch_file(self.patches.first.file)
		else
			raise RuntimeError, "Rubyfocs::OSSFetcher looking for zip files at #{url}: none found."
		end
	end

	# Fetches the ID Of the base file
	def base_id
		if self.patches.size > 0
			base_file = self.patches.first
			if base_file.file =~ /^\d+\=.*\+(.*)\.zip$/
				$1
			else
				raise RuntimeError, "Malformed patch file #{base_file}."
			end
		else
			raise RuntimeError, "Rubyfocs::OSSFetcher looking for zip files at #{url}: none found."
		end
	end

	# Fetches a list of every patch file
	def patches
		@patches ||= begin
			response = self.fetcher.get(url, digest_auth: auth).body
			# Text is in first table, let's assume
			table = response[/<table>(.*?)<\/table>/m,1]
			if table
				links = table.scan(/<a href="([^"]+)"/).flatten.select{ |f| f.end_with?(".zip") }
				puts "Patches are #{links}"
				links.map{ |u| Rubyfocus::Patch.new(self,u) }
			else
				[]
			end
		end
	end

	# Fetches the contents of a given patch file
	def patch(file)
		fetch_file(file)
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
		f = File.join(url,f)
		data = self.fetcher.get(f, digest_auth: auth).body
		# TODO Can you read directly from datastream?
		t = Tempfile.new("rubyfocus")
		t.write(data)
		t.close
		Zip::File.open(t.path){ |z| z.get_entry("contents.xml").get_input_stream.read }
	end
end