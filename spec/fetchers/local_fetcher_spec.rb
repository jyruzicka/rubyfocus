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

  let(:encrypted_fetcher) do
    fetcher = Rubyfocus::LocalFetcher.new
    fetcher.location = File.join(SPEC_ROOT, "/files/encrypted.ofocus")
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

  describe "#container_location" do
    it("should select system container location by default") do
      lf = Rubyfocus::LocalFetcher.new()

      expect(lf.container_location).to eq(File.join(ENV["HOME"], "Library/Containers/"))
    end

    it("should use a custom container location when specified") do
      lf = Rubyfocus::LocalFetcher.new()

      lf.container_location = "Foobar"

      expect(lf.container_location).to eq("Foobar")
    end
  end

  describe "#default_location" do
    context("with one default location") do
      it("should pick the default location") do
        lf = Rubyfocus::LocalFetcher.new()
        lf.container_location = File.join(
          __dir__,
          "../files/test_library/with_one_default_location"
        )

        expect(lf.default_location).to eq(
          File.join(
            __dir__,
            "../files/test_library/with_one_default_location/com.omnigroup.OmniFocus3/Data/Library/Application Support/OmniFocus/OmniFocus.ofocus"
          )
        )
      end
    end

    context("with two default locations") do
      it("should pick the latest location") do
        lf = Rubyfocus::LocalFetcher.new()
        lf.container_location = File.join(
          __dir__,
          "../files/test_library/with_two_default_locations"
        )

        expect(lf.default_location).to eq(
          File.join(
            __dir__,
            "../files/test_library/with_two_default_locations/com.omnigroup.OmniFocus3/Data/Library/Application Support/OmniFocus/OmniFocus.ofocus"
          )
        )
      end
    end

    context("with no default locations") do
      it("should return a blank string") do
        lf = Rubyfocus::LocalFetcher.new()
        lf.container_location = File.join(
          __dir__,
          "../files/test_library/with_no_default_locations"
        )

        expect(lf.default_location).to eq("")
      end
    end
  end

  describe "#appstore_location" do
    context("with one appstore location") do
      it("should pick the appstore location") do
        lf = Rubyfocus::LocalFetcher.new()
        lf.container_location = File.join(
          __dir__,
          "../files/test_library/with_one_appstore_location"
        )

        expect(lf.appstore_location).to eq(
          File.join(
            __dir__,
            "../files/test_library/with_one_appstore_location/com.omnigroup.OmniFocus3.MacAppStore/Data/Library/Application Support/OmniFocus/OmniFocus.ofocus"
          )
        )
      end
    end

    context("with two appstore locations") do
      it("should pick the latest location") do
        lf = Rubyfocus::LocalFetcher.new()
        lf.container_location = File.join(
          __dir__,
          "../files/test_library/with_two_appstore_locations"
        )

        expect(lf.appstore_location).to eq(
          File.join(
            __dir__,
            "../files/test_library/with_two_appstore_locations/com.omnigroup.OmniFocus3.MacAppStore/Data/Library/Application Support/OmniFocus/OmniFocus.ofocus"
          )
        )
      end
    end

    context("with no appstore locations") do
      it("should return a blank string") do
        lf = Rubyfocus::LocalFetcher.new()
        lf.container_location = File.join(
          __dir__,
          "../files/test_library/with_no_appstore_locations"
        )

        expect(lf.appstore_location).to eq("")
      end
    end
  end

  describe "#location" do
    it "should fetch the assigned location when one is set" do
      f = Rubyfocus::LocalFetcher.new
      f.location = "foobar"
      expect(f.location).to eq("foobar")
    end

    describe "when no location is set" do
      it "should fetch the default location if it exists" do
        f = Rubyfocus::LocalFetcher.new
        # Set default location to somewhere that exists
        default_location = File.join(__dir__, "fetcher_spec.rb")
        f.instance_variable_set("@default_location", default_location)

        expect(f.location).to eq(default_location)
      end

      it "should fetch the appstore location if default location doesn't exist" do
        f = Rubyfocus::LocalFetcher.new
        # Set default location to somewhere that exists
        fake_location = File.join(__dir__, "does_not_exist")
        default_location = File.join(__dir__, "fetcher_spec.rb")

        f.instance_variable_set("@default_location", fake_location)
        f.instance_variable_set("@appstore_location", default_location)

        expect(f.location).to eq(default_location)
      end

      it "should return nil if neither location exists" do
        f = Rubyfocus::LocalFetcher.new
        # Set default location to somewhere that exists
        fake_location = File.join(__dir__, "does_not_exist")
        second_fake_location = File.join(__dir__, "does_not_exist_either")

        f.instance_variable_set("@default_location", fake_location)
        f.instance_variable_set("@appstore_location", second_fake_location)

        expect(f.location).to eq(nil)
      end
    end
  end

  describe "#encrypted?" do
    it "should return `true` if the file `encrypted` exists" do
      expect(basic_fetcher).to_not be_encrypted
      expect(advanced_fetcher).to_not be_encrypted
      expect(encrypted_fetcher).to be_encrypted
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