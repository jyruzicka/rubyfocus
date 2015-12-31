require_relative "../spec_helper"

describe Rubyfocus::IDRef do
	class IDRefTest
		include Rubyfocus::IDRef
		idref :target
		attr_accessor :document
	end

	describe ".idref" do
	  it "should create an idref" do
	    test = IDRefTest.new
	    expect(test.respond_to?(:target_id)).to be true
	  end

	  it "should fetch the correct thing from its document" do
	    test = IDRefTest.new
	    document = double("document")
	    test.document = document

	    expect(document).to receive(:find).with("12345").and_return(:target)
	    test.target_id = "12345"
	    expect(test.target).to eq(:target)
	  end

	  it "should return +null+ if the ID is null, regardless of whether it has a document or not" do
	    test = IDRefTest.new
	    expect(test.target).to eq(nil)
	  end
	end
end