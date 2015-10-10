require_relative "../spec_helper"

describe Rubyfocus::Project do
	before(:all) do
		@project = Rubyfocus::Project.new(nil, xml("project"))
		@last_review = Time.utc(2014,02,02,22,57,41)
	end

	describe "#initialize" do
		it "should extract relevant data from the node" do
		  expect(@project.container_id).to eq("lZkC2HwceOc")
		  expect(@project).to be_singleton
		  expect(@project.last_review).to eq(@last_review)
		  review_interval = @project.review_interval
		  expect(review_interval.size).to eq(3)
		  expect(review_interval.unit).to eq(:months)
		  expect(@project.order).to eq(:parallel)
		end
	end

	describe "#inspect" do
	  it "should form a well-made inspector" do
	    inspect_string = @project.inspect
	    expect(inspect_string).to start_with("#<Rubyfocus::Project")
	    expect(inspect_string).to include(%|container_id="lZkC2HwceOc"|)
			expect(inspect_string).to include(%|singleton=true|)
			expect(inspect_string).to include(%|last_review=#{@last_review.inspect}|)
			expect(inspect_string).to include(%|review_interval=3m|)
			expect(inspect_string).to include(%|order=:parallel|)
	  end
	end

	#---------------------------------------
	# Project convenience methods, mainly for filtering

	# Tells us if tasks remain
	describe "#tasks_remain?" do
		before(:each) do 
			@d = Rubyfocus::Document.new

	    @p = Rubyfocus::Project.new(@d)
	    @p.id = "project_id"

	    @t = Rubyfocus::Task.new(@d)
	    @t.container_id = "project_id"
	  end

	  it "should return true when undone tasks remain" do
	    expect(@p.tasks_remain?).to be true
	  end

	  it "should return false when all tasks are finished" do
	    @t.completed = Time.now
	    expect(@p.tasks_remain?).to be false
	  end

	  it "should return false when there are no tasks at all" do
	    @t.container = nil
	    expect(@p.tasks_remain?).to be false
	  end
	end

	# Status convenience methods
	describe "#on_hold?" do
		it "should return true when set" do
			@p = Rubyfocus::Project.new
		  @p.status = :inactive
		  expect(@p).to be_on_hold
		  expect(@p).to_not be_active
		  expect(@p).to_not be_completed
		  expect(@p).to_not be_dropped
		end
	end

	describe "#active?" do
		it "should return true when set" do
			@p = Rubyfocus::Project.new
	  	@p.status = :active
	  	expect(@p).to_not be_on_hold
		  expect(@p).to be_active
		  expect(@p).to_not be_completed
		  expect(@p).to_not be_dropped
		end
	end

	describe "#dropped?" do
		it "should return true when set" do
			@p = Rubyfocus::Project.new
	  	@p.status = :dropped
	  	expect(@p).to_not be_on_hold
		  expect(@p).to_not be_active
		  expect(@p).to_not be_completed
		  expect(@p).to be_dropped
		end
	end

	describe "#completed?" do
		it "should return true when set" do
			@p = Rubyfocus::Project.new
	  	@p.status = :done
	  	expect(@p).to_not be_on_hold
		  expect(@p).to_not be_active
		  expect(@p).to be_completed
		  expect(@p).to_not be_dropped
		end
	end
end