require_relative "../spec_helper"

describe Rubyfocus::ConditionalExec do

  class CETestClass
    include Rubyfocus::ConditionalExec
    attr_accessor :foo
  end

  describe "#conditional_set" do
    it "should not set if object is nil" do
      test = CETestClass.new
      test.foo = 3
      test.conditional_set(:foo, nil){ 4 }
      expect(test.foo).to eq(3)
    end

    it "should set if the object is truthful" do
      test = CETestClass.new
      test.foo = 3
      test.conditional_set(:foo, true){ 4 }
      expect(test.foo).to eq(4)
    end
  end
end
