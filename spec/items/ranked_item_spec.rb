require_relative "../spec_helper"

describe Rubyfocus::RankedItem do
	before(:all) do
		@item = Rubyfocus::RankedItem.new(nil, xml(file: "ranked_item"))
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

	describe "ancestry methods" do
		before(:all) do 
			class FakeDocument
				include Rubyfocus::Searchable
				attr_accessor :array
				def initialize; @array = []; end
				def add_element(e); @array << e; e.document = self; end
			end

	  	@doc 					= FakeDocument.new
	  	@grandparent 	= Rubyfocus::RankedItem.new(@doc, id: "grandparent", 	name: "Grandparent")
	  	@parent		 		= Rubyfocus::RankedItem.new(@doc, id: "parent", 			name: "Parent", 	container: @grandparent)
	  	@item 				= Rubyfocus::RankedItem.new(@doc, id: "item", 				name: "Item", 		container: @parent)
	  end

		describe "#ancestry" do
			it "should give an ordered array of ancestors" do
				expect(@grandparent.ancestry).to eq([])
		  	expect(@parent.ancestry).to eq([@grandparent])
		  	expect(@item.ancestry).to eq([@parent, @grandparent])  
			end
		end
	  	
		describe "#contained_within?" do
		  it "should work with an object" do
	    	expect(@item.contained_within?(@parent)).to eq(true)
	    	expect(@item.contained_within?(@grandparent)).to eq(true)

	    	expect(@parent.contained_within?(@item)).to eq(false)
	    	expect(@parent.contained_within?(@grandparent)).to eq(true)

	    	expect(@grandparent.contained_within?(@item)).to eq(false)
	    	expect(@grandparent.contained_within?(@parent)).to eq(false)
		  end

		  it "should work with an id" do
	    	expect(@item.contained_within?("parent")).to eq(true)
	    	expect(@item.contained_within?("grandparent")).to eq(true)

	    	expect(@parent.contained_within?("item")).to eq(false)
	    	expect(@parent.contained_within?("grandparent")).to eq(true)

	    	expect(@grandparent.contained_within?("item")).to eq(false)
	    	expect(@grandparent.contained_within?("parent")).to eq(false)
		  end

		  it "should work with a hash" do
		    expect(@item.contained_within?(name: "Parent")).to eq(true)
	    	expect(@item.contained_within?(name: "Grandparent")).to eq(true)

	    	expect(@parent.contained_within?(name: "Item")).to eq(false)
	    	expect(@parent.contained_within?(name: "Grandparent")).to eq(true)

	    	expect(@grandparent.contained_within?(name: "Item")).to eq(false)
	    	expect(@grandparent.contained_within?(name: "Parent")).to eq(false)
		  end

		  it "should work even with multiple objects that have the same property" do
		    new_parent = Rubyfocus::RankedItem.new(@doc,id: "different-parent", name: "Parent")
	  		new_item = Rubyfocus::RankedItem.new(@doc, 	id: "different-item", 	name: "Item", container: new_parent)
	  		
	  		# Both these should return true
	  		expect(new_item.contained_within?(name: "Parent")).to eq(true)
	  		expect(@item.contained_within?(name: "Parent")).to eq(true)
		  end
		end
	end
end