require_relative "spec_helper"

# Test core extension methods applied to Time
describe Time do
  describe ".safely_parse" do
    it "should return a proper time if a proper time is provided" do
      expect(Time.safely_parse("04/08/2015").year).to eq(2015)
    end

    it "should return nil for nil or empty strings" do
      expect(Time.safely_parse nil).to be_nil
      expect(Time.safely_parse "").to be_nil
    end
  end
end