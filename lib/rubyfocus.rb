require "time"
require "nokogiri"
require "zip"
require "yaml"
require "httparty"

module Rubyfocus; end
# Require library files
Dir[File.join(__dir__, "rubyfocus/includes/*")].each{ |f| require f }
%w(fetcher local_fetcher oss_fetcher).each{ |f| require File.join(__dir__, "rubyfocus/fetchers", f) }
Dir[File.join(__dir__, "rubyfocus/*.rb")].each{ |f| require f }

# Need to load items in a specific order
%w(item named_item ranked_item task project context folder setting).each do |f|
  require File.join(__dir__, "rubyfocus/items", f)
end
