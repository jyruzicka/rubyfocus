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

    it "should not choke on empty string values" do
      t = Rubyfocus::Task.new(nil, xml("task-nostart"))
      expect(t.start).to be_nil
    end
  end

  it "should set Task#flagged to false by default" do
		unflagged_task = Rubyfocus::Task.new(nil, xml("task-unflagged"))
		expect(unflagged_task.flagged).to eq(false)
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

  describe "#tasks" do
    it "should fetch sub-tasks" do
      d = Rubyfocus::Document.new
      t = Rubyfocus::Task.new(d, id: "Sample")
      t2 = Rubyfocus::Task.new(d, id: "Task 2", container: t)

      expect(t.tasks).to include(t2)
    end

    it "should exclude sub-tasks that in turn have sub-tasks, but include their tasks" do
      d = Rubyfocus::Document.new
      t = Rubyfocus::Task.new(d, id: "Sample")
      t2 = Rubyfocus::Task.new(d, id: "Subtask", container: t)
      t3 = Rubyfocus::Task.new(d, id: "Sub-sub task", container: t2)

			expect(t.tasks).to_not include(t2)
      expect(t.tasks).to include(t3)
    end
  end

  describe "#immediate_tasks" do
    it "should fetch immediate sub-tasks" do
      d = Rubyfocus::Document.new
      t = Rubyfocus::Task.new(d, id: "Sample")
      t2 = Rubyfocus::Task.new(d, id: "Subtask", container: t)

      expect(t.immediate_tasks).to include(t2)
    end

    it "should include sub-tasks that in turn have sub-tasks, but exclude their tasks" do
      d = Rubyfocus::Document.new
      t = Rubyfocus::Task.new(d, id: "Sample")
      t2 = Rubyfocus::Task.new(d, id: "Subtask", container: t)
      t3 = Rubyfocus::Task.new(d, id: "Sub-subtask", container: t2)

			expect(t.immediate_tasks).to include(t2)
      expect(t.immediate_tasks).to_not include(t3)
    end
  end

  describe "#next_available_task" do
    it "should fetch the next non-blocked task - simple case" do
    	d = Rubyfocus::Document.new
    	
      p = Rubyfocus::Task.new(d, id: "12345")
      t = Rubyfocus::Task.new(d, id: "First task", container: p, rank: 1)
      t2 = Rubyfocus::Task.new(d, id: "Second task", container: p, rank: 0)
      expect(p.next_available_task).to eq(t2)
    end

    it "should fetch the next non-blocked task, even when it's buried" do
      d = Rubyfocus::Document.new
      
      p = Rubyfocus::Task.new(d, id: "12345")
      t = Rubyfocus::Task.new(d, id: "First task", container: p, rank: 2)
      t2 = Rubyfocus::Task.new(d, id: "Second task", container: p, rank: 1)
      t3 = Rubyfocus::Task.new(d, id: "Third task", container: t2, rank: 3)

      expect(p.next_available_task).to eq(t3)
    end

    it "should return nil when project has no tasks" do
      d = Rubyfocus::Document.new
      p = Rubyfocus::Task.new(d, id: "12345")

      expect(p.next_available_task).to eq(nil)
    end
  end

  describe "#has_subtasks?" do
    it "should return false if a task has no subtasks" do
      d = Rubyfocus::Document.new
      t = Rubyfocus::Task.new(d, id: "Task")

      expect(t.has_subtasks?).to eq(false)
    end

    it "should return true if a task has subtasks" do
      d = Rubyfocus::Document.new
      t = Rubyfocus::Task.new(d,id: "12345")
      t2 = Rubyfocus::Task.new(d, id: "Task 2", container: t)

      expect(t.has_subtasks?).to eq(true)
    end
  end

  describe "#deferred?" do
    it "should return false if task's start date is not set" do
      expect(Rubyfocus::Task.new(nil)).to_not be_deferred
    end

    it "should return false if task's start date is set to the past" do
      expect(Rubyfocus::Task.new(nil,start:Time.now-1)).to_not be_deferred
    end

    it "should return true if task's start date is set in the future" do
      expect(Rubyfocus::Task.new(nil,start:Time.now+60)).to be_deferred
    end
  end

	# Incomplete tasks are those which aren't completed
	describe "#incomplete_tasks" do
	  it "should catch incomplete tasks, and avoid complete ones" do
	    d = Rubyfocus::Document.new

	    p = Rubyfocus::Task.new(d, id: "sample id", order: :parallel)
	    t = Rubyfocus::Task.new(d, id: "First task", container: p)
	    t2 = Rubyfocus::Task.new(d, id: "Second task", container: p, completed: Time.now)

	    expect(p.incomplete_tasks).to include(t)
	    expect(p.incomplete_tasks).to_not include(t2)
	  end
	end

	# Next tasks are those which aren't complete and aren't blocked
	describe "#next_tasks" do
	  it "should catch tasks by default" do
	  	d = Rubyfocus::Document.new
	    p = Rubyfocus::Task.new(d, id: "sample id", order: :parallel)
	    t = Rubyfocus::Task.new(d, id: "Task", container: p)

	    expect(p.next_tasks).to include(t)
	  end

	  it "should not catch completed tasks" do
	    d = Rubyfocus::Document.new
	    
	    p = Rubyfocus::Task.new(d, id: "sample id", order: :parallel)
	    t = Rubyfocus::Task.new(d, id: "First task", container: p)
	    t2 = Rubyfocus::Task.new(d, id: "Second task", container: p, completed: Time.now)

	    expect(p.next_tasks).to include(t)
	    expect(p.next_tasks).to_not include(t2)
	  end

	  it "should not catch tasks that are blocked in a sequential group" do
	    d = Rubyfocus::Document.new

	    p = Rubyfocus::Task.new(d, id: "sample id", order: :sequential)
	    t = Rubyfocus::Task.new(d, id: "First task", container: p, order: 1)
	    t2 = Rubyfocus::Task.new(d, id: "Second task", container: p, order: 2)

	    expect(p.next_tasks).to include(t)
	    expect(p.next_tasks).to_not include(t2)
	  end

	  it "should not catch tasks that are blocked in a sequential subtask" do
	    d = Rubyfocus::Document.new

	    p = Rubyfocus::Task.new(d, id: "sample id", order: :parallel)

	    t = Rubyfocus::Task.new(d, id: "First task", container: p, order: :sequential)
	    t2 = Rubyfocus::Task.new(d, id: "Second task", container: t)
	    t3 = Rubyfocus::Task.new(d, id: "Third task", container: t)

	    expect(p.next_tasks).to include(t2)
	    expect(p.next_tasks).to_not include(t3)
	    expect(p.next_tasks).to_not include(t)
	  end

	  it "should not catch tasks whose container is blocked" do
	    d = Rubyfocus::Document.new

	    p = Rubyfocus::Project.new(d, id: "Containing project", order: :sequential)

	    t1 = Rubyfocus::Task.new(d, id: "First task", container: p, rank: 1)
	    t2 = Rubyfocus::Task.new(d, id: "Second task", container: p, rank: 2)
	    t3 = Rubyfocus::Task.new(d, id: "First subtask", container: t1)
	    t4 = Rubyfocus::Task.new(d, id: "Second subtask", container: t2)

	    expect(p.next_tasks).to eq([t3])
	  end
	end

	# Actionable tasks are next tesks which aren't deferred
	describe "#actionable_tasks" do
	  it "should not catch tasks that start in the future" do
			d = Rubyfocus::Document.new
			
	    p = Rubyfocus::Task.new(d, id: "Project", order: :parallel)
	    t = Rubyfocus::Task.new(d, id: "Sample task", container: p)
	    t2 = Rubyfocus::Task.new(d, id: "Second task", container: p, start: Time.now+60*60*24)

	    expect(p.actionable_tasks).to include(t)
	    expect(p.actionable_tasks).to_not include(t2)
	  end
	end

	# Blocked tasks are tasks which cannot be completed until another
	# task is completed
	describe "#blocked?" do
	  it "should return true if it's the second task in a sequential list" do
	    d = Rubyfocus::Document.new
	    p = Rubyfocus::Task.new(d, id: "Project", order: :sequential)
	    t1 = Rubyfocus::Task.new(d, id: "Subtask 1", container: p, rank: 1)
	    t2 = Rubyfocus::Task.new(d, id: "Subtask 2", container: p, rank: 0)

	    expect(t1).to be_blocked
	    expect(t2).to_not be_blocked
	  end

	  it "should return false if it's in a non-blocked parallel list" do
			d = Rubyfocus::Document.new
	    p = Rubyfocus::Task.new(d, id: "Project", order: :parallel)
	    t1 = Rubyfocus::Task.new(d, id: "Subtask 1", container: p, rank: 1)
	    t2 = Rubyfocus::Task.new(d, id: "Subtask 2", container: p, rank: 0)

	    expect(t1).to_not be_blocked
	    expect(t2).to_not be_blocked
	  end

	  it "should return true if it's contained by a folder" do
	    d = Rubyfocus::Document.new
	    f = Rubyfocus::Folder.new(d, id: "folder")
	    p1 = Rubyfocus::Project.new(d, id:"Project 1", container: f)
	    p2 = Rubyfocus::Project.new(d, id:"Project 2", container: f)

	    expect(p1).to_not be_blocked
	    expect(p2).to_not be_blocked
	  end

	  it "should return true if its parent is blocked" do
	    d = Rubyfocus::Document.new
	    p = Rubyfocus::Task.new(d, id: "Project", order: :sequential)
	    c1 = Rubyfocus::Task.new(d, id: "Container 1", container: p, rank: 1)
	    c2 = Rubyfocus::Task.new(d, id: "Container 2", container: p, rank: 0)

			t1 = Rubyfocus::Task.new(d, id: "Subtask 1", container: c1, rank: 1)
	    t2 = Rubyfocus::Task.new(d, id: "Subtask 2", container: c1, rank: 0)
	    t3 = Rubyfocus::Task.new(d, id: "Subtask 3", container: c2, rank: 1)
	    t4 = Rubyfocus::Task.new(d, id: "Subtask 4", container: c2, rank: 0)	

	    # p
	    # + c2
	    #   + t4
	    #   + t3
	    # + c1
	    # 	+ t2
	    # 	+ t1    

	    expect(p).to_not be_blocked
	    expect(c1).to be_blocked
	    expect(c2).to_not be_blocked
	    expect(t1).to be_blocked
	    expect(t2).to be_blocked
	    expect(t3).to be_blocked
	    expect(t4).to_not be_blocked
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