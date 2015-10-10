require_relative "../spec_helper"

describe Rubyfocus::Context do
	describe "with location" do
		before(:all) do
			@context = Rubyfocus::Context.new(nil, xml("context-location"))
		end

  	describe "#initialize" do
		 	it "should extract data correctly" do
		 	  loc = @context.location
		 	  expect(loc.name).to eq("Location name")
		 	  expect(loc.latitude).to eq(-40)
		 	  expect(loc.longitude).to eq(170)
		 	  expect(loc.radius).to eq(1)
		 	  expect(loc.notification_flags).to eq(0)
		 	  expect(@context.container_id).to be_nil
		 	end
	 	end
  end

  describe "with parent context" do
  	before(:all) do
  		@context = Rubyfocus::Context.new(nil, xml("context-parent"))
  	end

  	describe "#initialize" do
  	  it "should extract data correctly" do
  	    expect(@context.location).to be_nil
  	    expect(@context.container_id).to eq("nkGRbmiwyUE")
  	  end
  	end
  end
end