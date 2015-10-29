require_relative "../spec_helper"
Struct.new("Responder", :body)
Struct.new("Fetcher", :_get){ def get(url,hsh); return _get; end }
describe Rubyfocus::OSSFetcher do
  let(:html){ <<-end
<html><table>
  <tr><td><a href="20151016190000=basefile_id+basefile.zip">foo</a></td></tr>
  <tr><td><a href="20151016190100=basefile+patch1.zip">foo</a></td></tr>
  <tr><td><a href="20151016190200=patch1+patch2.zip">foo</a></td></tr>
  <tr><td><a href="20151016190300=patch2+patch3.zip">foo</a></td></tr>
</table></html>
  end
  }

  let(:base_fetcher) {
    r = Struct::Responder.new(html)
    
    fetcher = Struct::Fetcher.new(r)

    f = Rubyfocus::OSSFetcher.new("foo", "bar")
    f.fetcher = fetcher
    f
  }

  describe "#patches" do
    it "should return a list of files, as HTML" do
      r = double(body: html)

      fetcher = double("Fetcher")
      expect(fetcher).to receive(:get).with("https://sync.omnigroup.com/foo/OmniFocus.ofocus", digest_auth: {username: "foo", password: "bar"} ).and_return(r)

      f = Rubyfocus::OSSFetcher.new("foo", "bar")
      f.fetcher = fetcher

      patches = f.patches
      expect(patches.first.file).to eq("20151016190000=basefile_id+basefile.zip")
      expect(patches.last.file).to eq("20151016190300=patch2+patch3.zip")
    end
  end

  describe "#base_id" do
    it "should return the id of the base" do
      expect(base_fetcher.base_id).to eq("basefile")
    end
  end

  describe "#patch" do
    it "should retrieve and unzip a zipped file" do
      # First, collect some zipped data
      zip_file = Dir[File.join(file("basic.ofocus"),"*.zip")].first
      zipped_data = File.read(zip_file)

      r = double(body: zipped_data)
      fetcher = double(get: r)

      f = Rubyfocus::OSSFetcher.new("foo", "bar")
      f.fetcher = fetcher
      expect(f.patch("random")).to include(%|<?xml version="1.0" encoding="UTF-8" standalone="no"?>|)
    end
  end
end