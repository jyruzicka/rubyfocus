require_relative "../spec_helper"
require "tempfile"

describe Rubyfocus::LocalFetcher do
	let(:basic_fetcher) do
		fetcher = Rubyfocus::LocalFetcher.new
    fetcher.location = File.join(SPEC_ROOT, "/files/basic.ofocus")
    fetcher
  end

  let(:advanced_fetcher) do
    fetcher = Rubyfocus::LocalFetcher.new
    fetcher.location = File.join(SPEC_ROOT, "/files/advanced.ofocus")
    fetcher
  end


  describe "#base" do
    it "should parse + return the contents of the base file" do
    	expect(basic_fetcher.base).to start_with(%|<?xml version="1.0" encoding="UTF-8" standalone="no"?>|)
    end
  end

  describe "#base_id" do
    it "should return the id of the base file" do
      expect(basic_fetcher.base_id).to eq("lNOvLYu2pV5")
    end
  end

  describe "#patches" do
    it "should return all the patch file names in the update" do
      patches = basic_fetcher.patches
      expect(patches.size).to eq(1)
      expect(patches[0].from_ids).to eq(["lNOvLYu2pV5"])
    end
  end

  describe "#patch" do
    it "should fetch the contents of the given patch" do
      first_patch = basic_fetcher.patches.first.file
      patch_contents = basic_fetcher.patch(first_patch)
      expect(patch_contents).to start_with(%|<?xml version="1.0" encoding="UTF-8" standalone="no"?>|)
    end
  end

  describe "integration tests" do
    it "should apply patches incrementally" do
      d = Rubyfocus::Document.new(basic_fetcher)
      expect(d.tasks.size).to eq(1)
      expect(d.folders.size).to eq(0)
      expect(d.tasks.first.name).to eq("Sample task")

      # Next iteration
      d.fetcher.update_once(d)
      expect(d.folders.size).to eq(1)
      expect(d.tasks.first.name).to eq("Sample task updated")
    end

    it "should properly save and load documents" do
      d = Rubyfocus::Document.new(advanced_fetcher)
      d.fetcher.update_once(d)

      expect(d.folders.first.name).to eq("Sample folder")

      # We will save and load
      f = Tempfile.new("rubyfocus")
      f.close

      d.save(f.path)
      
      d2 = Rubyfocus::Document.load_from_file(f.path)
      expect(d2.patch_id).to eq("12RdY7iO2P")
      expect(d2.folders.first.name).to eq("Sample folder")
      d2.fetcher.update_once(d2)
      expect(d2.folders.first.name).to eq("Sample folder updated")
    end
  end
end