require_relative "spec_helper"

def patch(text)
	%|<?xml version="1.0" encoding="utf-8" standalone="no"?><omnifocus xmlns="http://www.omnigroup.com/namespace/OmniFocus/v1">#{text}</omnifocus>|
end

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

	describe "#can_patch?" do
	  it "should return false if patch's from_ids don't include document's" do
	    d = Rubyfocus::Document.new
	    d.patch_id = "12345"

	    p = Rubyfocus::Patch.new
	    p.from_ids = ["abcdef"]

	    expect(p.can_patch?(d)).to eq(false)
	  end
	end

	describe "#apply_to" do
	  it "should not run if patch and document ids don't match" do
	    d = Rubyfocus::Document.new
	    d.patch_id = "12345"

	    p = Rubyfocus::Patch.new
	    p.from_ids = ["abcdef"]

	    expect{ p.apply_to(d) }.to raise_error(RuntimeError)
	  end

	  it "should run if patch and document ids match" do
	    d = Rubyfocus::Document.new
	    d.patch_id = "12345"

	    p = Rubyfocus::Patch.from_string(nil, patch(""))
	    p.from_ids = ["abcdef", "12345"]

	    p.apply_to(d)
	  end
	end

	describe "#apply_to!" do
	  it "should apply create patches to create things" do
	    d = Rubyfocus::Document.new
	    p = Rubyfocus::Patch.from_string(nil, patch(%|<task id="12345"></task>|))
	    p.apply_to!(d)
	    expect(d.tasks.size).to eq(1)
	  end

	  it "should apply update patches to update things" do
	    d = Rubyfocus::Document.new
	    Rubyfocus::Task.new(d, id: "12345")
	    expect(d.tasks.size).to eq(1)

	    p = Rubyfocus::Patch.from_string(nil, patch(%|<task id="12345" op="update"><name>Sample name</name></task>|))
	    p.apply_to!(d)
	    expect(d.tasks.first.name).to eq("Sample name")
	    expect(d.tasks.size).to eq(1)
	  end

	  it "should apply delete patches to delete things" do
	    d = Rubyfocus::Document.new
	    Rubyfocus::Task.new(d, id: "12345")
	    expect(d.tasks.size).to eq(1)

	    p = Rubyfocus::Patch.from_string(nil, patch(%|<task id="12345" op="delete"></task>|))
	    p.apply_to!(d)
	    expect(d.tasks.size).to eq(0)
	  end

	  it "should apply update patches to promote tasks to projects" do
	    d = Rubyfocus::Document.new
	    Rubyfocus::Task.new(d, id: "12345")
	    expect(d.tasks.size).to eq(1)

	    p = Rubyfocus::Patch.from_string(nil, patch(%|<task id="12345" op="update"><project></project></task>|))
	    p.apply_to!(d)
	    expect(d.tasks.size).to eq(0)
	    expect(d.projects.size).to eq(1)
	  end

	  it "should apply update patches to demote projects to tasks" do
	    d = Rubyfocus::Document.new
	    Rubyfocus::Project.new(d, id: "12345")
	    expect(d.projects.size).to eq(1)

	    p = Rubyfocus::Patch.from_string(nil, patch(%|<task id="12345" op="update"></task>|))
	    p.apply_to!(d)
	    expect(d.tasks.size).to eq(1)
	    expect(d.projects.size).to eq(0)
	  end
	end
end