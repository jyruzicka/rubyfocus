require_relative "spec_helper"

describe Rubyfocus::Patch do
	before(:all) do
		@update = Rubyfocus::Patch.new
		patch_data = File.read(file "basic-update.xml")
		@update.load_data patch_data
	end

	it "should store create, delete and update operations" do
		expect(@update.update.size).to eq(2)
		expect(@update.create.size).to eq(1)
		expect(@update.delete.size).to eq(3)
	end

	describe "#patch_ids" do
	  it "should identify from_id and to_id given a complex filename" do
	  	p = Rubyfocus::Patch.new(nil,"20151010145000=abc1234+tRof645+o03Cro.zip")
	  	expect(p.from_ids).to eq(["abc1234", "tRof645"])
	  	expect(p.to_id).to eq("o03Cro")
	  end
	end
end