require_relative "../spec_helper"

describe Rubyfocus::NamedItem do
  before(:all) do
    @item = Rubyfocus::NamedItem.new(nil, xml(file: "named_item"))
  end

  describe "#initialize" do
    it "should extract relevant data from the node" do
      expect(@item.name).to eq("Foo Bar")
    end
  end

  describe "#inspect" do
    it "should form a well-made inspector" do
      inspect_string = @item.inspect
      expect(inspect_string).to start_with("#<Rubyfocus::NamedItem")
      expect(inspect_string).to include(%|name="Foo Bar"|)
    end
  end
end
