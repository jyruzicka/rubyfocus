require_relative "../spec_helper"

describe Rubyfocus::Folder do
  before(:all) do
    @folder = Rubyfocus::Folder.new(nil, xml(file: "folder"))
    @orphan_folder = Rubyfocus::Folder.new(nil, xml(file: "orphan_folder"))
  end

  describe "#initialize" do
    it "should extract relevant data from the node" do
      expect(@folder.container_id).to eq("dy6QTx6pCUz")
      expect(@orphan_folder.container_id).to be_nil
    end
  end

  describe "#inspect" do
    it "should form a well-made inspector" do
      inspect_string = @folder.inspect
      expect(inspect_string).to start_with("#<Rubyfocus::Folder")
      expect(inspect_string).to include(%|container_id="dy6QTx6pCUz"|)

      orphan_string = @orphan_folder.inspect
      expect(orphan_string).to_not include(%|container_id|)
    end
  end
end
