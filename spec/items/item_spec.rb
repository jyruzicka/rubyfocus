require_relative "../spec_helper"

describe Rubyfocus::Item do
  before(:all) do
    @item = Rubyfocus::Item.new(nil, xml(file: "item"))
    @added_at = Time.utc(2014,01, 01, 21, 15, 30)
    @modified_at = Time.utc(2014,02, 01, 22, 30, 00)
  end

  describe "#initialize" do
    it "should extract relevant data from the node" do
      expect(@item.id).to eq("foobar")
      expect(@item.added).to eq(@added_at)
      expect(@item.modified).to eq(@modified_at)
    end
  end

  describe "#inspect" do
    it "should form a well-made inspector" do
      inspect_string = @item.inspect
      expect(inspect_string).to start_with("#<Rubyfocus::Item")
      expect(inspect_string).to end_with(">")
      expect(inspect_string).to include(%|id="foobar"|)
      expect(inspect_string).to include(%|added=#{@added_at.inspect}|)
      expect(inspect_string).to include(%|modified=#{@modified_at.inspect}|)
    end
  end

  describe "#document=" do
    it "should not run add_element (check against previous behavour)" do
      d = Rubyfocus::Document.new

      t = Rubyfocus::Task.new(nil, id:"foo")
      t.document = d

      expect(d.tasks.size).to eq(0)
    end
  end
end
