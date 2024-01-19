require_relative "../spec_helper"

# Tests for the normal fetcher methods

describe Rubyfocus::Fetcher do

  class TestFetcher < Rubyfocus::Fetcher
    def patches
      [
        Rubyfocus::Patch.new(self, "20160101103000=abc+def.zip"),
        Rubyfocus::Patch.new(self, "20160101103100=abc+123.zip"),
        Rubyfocus::Patch.new(self, "20160101103200=def+ghi.zip"),
        Rubyfocus::Patch.new(self, "20160101103300=def+xyz.zip"),
        Rubyfocus::Patch.new(self, "20160101103400=123+456.zip"),
        Rubyfocus::Patch.new(self, "20160101103500=ghi+jkl.zip")
      ]
    end

    def next_patch(d)
      @next_patch
    end

    def next_patch=(p)
      @next_patch = p
    end
  end

  before(:each) do
    @fetcher = TestFetcher.new
  end

  describe "#head" do
    it "should retrieve the ID of the latest patch" do
      expect(@fetcher.head).to eq("jkl")
    end
  end

  describe "#can_reach_head_from?" do
    it "should return true if you can reach the head from the given patch ID" do
       expect(@fetcher.can_reach_head_from?("abc")).to eq(true)
       expect(@fetcher.can_reach_head_from?("def")).to eq(true)
       expect(@fetcher.can_reach_head_from?("ghi")).to eq(true)
       expect(@fetcher.can_reach_head_from?("xyz")).to eq(false)
       expect(@fetcher.can_reach_head_from?("bar")).to eq(false)
       expect(@fetcher.can_reach_head_from?("123")).to eq(false)
    end
  end

  describe "#can_patch?" do
    it "should return true when next_patch is not nil" do
      @fetcher.next_patch = 3
      expect(@fetcher.can_patch?(nil)).to eq(true)
      @fetcher.next_patch = nil
      expect(@fetcher.can_patch?(nil)).to eq(false)
    end
  end

  describe "#encrypted?" do
    it "should return a RuntimeError for basic fetchers" do
      expect{ Rubyfocus::Fetcher.new.encrypted? }.to raise_error(RuntimeError)
    end
  end
end
