require_relative "spec_helper"

describe Rubyfocus::Document do
	before(:all) do
		@doc = Rubyfocus::Document.from_xml file("document.xml")
	end

	it "should get all elements, and ignore weird ones" do
		expect(@doc.elements.size).to eq(3)
	end

	it "should separate projects, tasks, etc" do
	  expect(@doc.projects.size).to eq(1)
	  expect(@doc.tasks.size).to eq(1)
	  expect(@doc.contexts.size).to eq(1)
	end

	it "should find elements by id" do
	  expect(@doc["12345"].class).to eq(Rubyfocus::Task)
	  expect(@doc["does not exist"]).to eq(nil)
	end

	describe "#add_element", focus: true do
		it "should throw an exception if we try to add an element with a duplicate ID" do
			expect {
				d = Rubyfocus::Document.new

				Rubyfocus::Task.new(d, id: "Sample ID")
				Rubyfocus::Task.new(d, id: "Sample ID")
			}.to raise_exception(Rubyfocus::DocumentElementException)
		end

		it "should not throw an exception if we set allow_duplicate_ids" do
			d = Rubyfocus::Document.new
			d.allow_duplicate_ids = true

			# So this should not raise an error
		  Rubyfocus::Task.new(d, {id: "Sample ID"})
			Rubyfocus::Task.new(d, {id: "Sample ID"})
		end
	end
end