require_relative "../spec_helper"

class IDRefTestClass
	include Rubyfocus::IDRef
	attr_accessor :document
	idref :foo
end

describe IDRefTestClass do
	before(:each) do
		@t = IDRefTestClass.new
		@t.foo_id = "bar"
	end

  it "should correctly fetch when given a document" do
  	doc = double("document")
  	ref = double("reference")
  	expect(doc).to receive(:find).with("bar"){ ref }

  	@t.document = doc
  	expect(@t.foo).to eq(ref)
  end

  it "should return nil when it doesn't have a document" do
    expect(@t.foo).to be_nil
  end

  it "should return nil when it doesn't have an id" do
    @s = IDRefTestClass.new
    expect(@s.foo).to be_nil

    @s.document = double("document")
		expect(@s.foo).to be_nil    
  end

  it "should allow us to set using the idless setter and an id'd object" do
    id_object = double
    expect(id_object).to receive(:id){ "12345" }
    @t.foo = id_object
    expect(@t.foo_id).to eq("12345")
  end

  it "should throw an error if we try to set an idref to a non-id'd object" do
    expect{ @t.foo = 3}.to raise_error(ArgumentError)
  end

  it "should set foo_id to nil if foo is set to nil" do
    @t.foo = nil
    expect(@t.foo_id).to be_nil
  end
end