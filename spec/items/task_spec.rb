require_relative "../spec_helper"

describe Rubyfocus::Task do
	before(:all) do
		@task = Rubyfocus::Task.new(nil, xml("task"))
	end

  describe "#initialize" do
    it "should extract relevant data from node" do
		  expect(@task.container_id).to eq("agkBVCwMAp1")
		  expect(@task.context_id).to eq("oiHHWDl5Fuv")
		  expect(@task.note).to eq("<text>Sample text goes here.</text>")
		  expect(@task.order).to eq(:parallel)
		  expect(@task.flagged).to eq(true)
		  expect(@task.start).to eq(Time.utc(2014,01,01,0,0,0))
		  expect(@task.due).to eq(Time.utc(2014,02,01,0,0,0))
    end
  end

  it "should set Task#flagged to false by default" do
		@unflagged_task = Rubyfocus::Task.new(nil, xml("task-unflagged"))
		expect(@unflagged_task.flagged).to eq(false)
  end

  describe "#inspect" do
    it "should form a well-made inspector" do
	    inspect_string = @task.inspect
	    expect(inspect_string).to start_with("#<Rubyfocus::Task")
	    expect(inspect_string).to include(%|container_id="agkBVCwMAp1"|)
	    expect(inspect_string).to include(%|context_id="oiHHWDl5Fuv"|)
	    expect(inspect_string).to include(%|order=:parallel|)
	    expect(inspect_string).to include(%|flagged=true|)
	    expect(inspect_string).to include(%|start=2014-01-01 00:00:00 UTC|)
	    expect(inspect_string).to include(%|due=2014-02-01 00:00:00 UTC|)
	  end
	end

	describe "subtasks" do
	  describe "#tasks" do
	    it "should fetch sub-tasks" do
	      @d = Rubyfocus::Document.new
	      @t = Rubyfocus::Task.new(@d, id: "Sample")
	      @t2 = Rubyfocus::Task.new(@d, container: @t)

	      expect(@t.tasks).to include(@t2)
	    end

	    it "should exclude sub-tasks that in turn have sub-tasks, but include their tasks" do
	      @d = Rubyfocus::Document.new
	      @t = Rubyfocus::Task.new(@d, id: "Sample")
	      @t2 = Rubyfocus::Task.new(@d, container: @t, id: "subtask")
	      @t3 = Rubyfocus::Task.new(@d, container: @t2)

				expect(@t.tasks).to_not include(@t2)
	      expect(@t.tasks).to include(@t3)
	    end
	  end
	end

	# Incomplete tasks are those which aren't completed
	describe "#incomplete_tasks" do
	  it "should catch incomplete tasks, and avoid complete ones" do
	    @d = Rubyfocus::Document.new
	    @p = Rubyfocus::Task.new(@d, id: "sample id", order: :parallel)
	    @t = Rubyfocus::Task.new(@d, container: @p)
	    @t2 = Rubyfocus::Task.new(@d, container: @p, completed: Time.now)

	    expect(@p.incomplete_tasks).to include(@t)
	    expect(@p.incomplete_tasks).to_not include(@t2)
	  end
	end

	# Next tasks are those which aren't complete and aren't blocked
	describe "#next_tasks" do
	  it "should catch tasks by default" do
	  	@d = Rubyfocus::Document.new
	    @p = Rubyfocus::Task.new(@d, id: "sample id", order: :parallel)
	    @t = Rubyfocus::Task.new(@d, container: @p)

	    expect(@p.next_tasks).to include(@t)
	  end

	  it "should not catch completed tasks" do
	    @d = Rubyfocus::Document.new
	    @p = Rubyfocus::Task.new(@d, id: "sample id", order: :parallel)
	    @t = Rubyfocus::Task.new(@d, container: @p)
	    @t2 = Rubyfocus::Task.new(@d, container: @p, completed: Time.now)

	    expect(@p.next_tasks).to include(@t)
	    expect(@p.next_tasks).to_not include(@t2)
	  end

	  it "should not catch tasks that are blocked in a sequential group" do
	    @d = Rubyfocus::Document.new
	    @p = Rubyfocus::Task.new(@d, id: "sample id", order: :sequential)
	    @t = Rubyfocus::Task.new(@d, container: @p, order: 1)
	    @t2 = Rubyfocus::Task.new(@d, container: @p, order: 2)

	    expect(@p.next_tasks).to include(@t)
	    expect(@p.next_tasks).to_not include(@t2)
	  end

	  it "should not catch tasks that are blocked in a sequential subtask" do
	    @d = Rubyfocus::Document.new
	    @p = Rubyfocus::Task.new(@d, id: "sample id", order: :parallel)

	    @t = Rubyfocus::Task.new(@d, container: @p, id: "task", order: :sequential)
	    @t2 = Rubyfocus::Task.new(@d, container: @t)
	    @t3 = Rubyfocus::Task.new(@d, container: @t)

	    expect(@p.next_tasks).to include(@t2)
	    expect(@p.next_tasks).to_not include(@t3)
	    expect(@p.next_tasks).to_not include(@t1)
	  end
	end

	# Actionable tasks are next tesks which aren't deferred
	describe "#actionable_tasks" do
	  it "should not catch tasks that start in the future" do
			@d = Rubyfocus::Document.new
	    @p = Rubyfocus::Task.new(@d, id: "sample id", order: :parallel)
	    @t = Rubyfocus::Task.new(@d, container: @p)
	    @t2 = Rubyfocus::Task.new(@d, container: @p, start: Time.now+60*60*24)

	    expect(@p.actionable_tasks).to include(@t)
	    expect(@p.actionable_tasks).to_not include(@t2)
	  end
	end

	#---------------------------------------
	# Conversion methods
	#---------------------------------------
	# Testing conversion of projects to tasks
	describe "#to_project" do
	  it "should return a project with all appropriate methods" do
	  	now = Time.now
	    t = Rubyfocus::Task.new(nil, {name: "Sample task", flagged: true, start: now})
	    p = t.to_project
	    expect(p.name).to eq("Sample task")
	    expect(p.start).to eq(now)
	    expect(p.flagged).to be true
	  end
	end
end