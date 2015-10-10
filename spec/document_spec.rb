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
end