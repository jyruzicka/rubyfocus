require_relative "../spec_helper"

describe Rubyfocus::RankedItem do
	before(:all) do
		@item = Rubyfocus::RankedItem.new(nil, xml("ranked_item"))
	end

	describe "#initialize" do
		it "should extract relevant data from the node" do
		  expect(@item.rank).to eq(-132)
		end
	end

	describe "#inspect" do
	  it "should form a well-made inspector" do
	    inspect_string = @item.inspect
	    expect(inspect_string).to start_with("#<Rubyfocus::RankedItem")
	    expect(inspect_string).to include(%|rank=-132|)
	  end
	end
end