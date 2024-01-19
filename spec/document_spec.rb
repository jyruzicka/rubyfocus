require_relative "spec_helper"

describe Rubyfocus::Document do
  before(:all) do
    @doc = Rubyfocus::Document.from_xml file("document.xml")
  end

  it "should get all elements, and ignore weird ones" do
    expect(@doc.elements.size).to eq(3)
  end

  it "should separate projects, tasks, etc" do
    expect(@doc.projects.size).to eq(1)
    expect(@doc.tasks.size).to eq(1)
    expect(@doc.contexts.size).to eq(1)
  end

  it "should find elements by id" do
    expect(@doc["12345"].class).to eq(Rubyfocus::Task)
    expect(@doc["does not exist"]).to eq(nil)
  end

  describe "#add_element" do
    it "should throw an exception if we try to add an element with a duplicate ID" do
      expect {
        d = Rubyfocus::Document.new

        Rubyfocus::Task.new(d, id: "Sample ID")
        Rubyfocus::Task.new(d, id: "Sample ID")
      }.to raise_exception(Rubyfocus::DocumentElementException)
    end

    it "should remove old elements if we set overwrite to true" do
      d = Rubyfocus::Document.new

      # So this should not raise an error
      t1 = Rubyfocus::Task.new(nil, {id: "Sample ID"})
      t2 = Rubyfocus::Task.new(nil, {id: "Sample ID"})

      d.add_element(t1)
      d.add_element(t2, overwrite: true)

      expect(d.tasks.size).to eq(1)
      expect(d.tasks.first).to eq(t2)
    end
  end

  describe "#update" do
    it "should raise an error if the fetcher is encrypted" do
      d = Rubyfocus::Document.new
      f = double("Fetcher")
      expect(f).to receive(:encrypted?).and_return(false)
      expect(f).to receive(:update_full).with(d)
      d.fetcher = f
      d.update

      ef = double("Fetcher")
      expect(ef).to receive(:encrypted?).and_return(true)
      d.fetcher = ef

      expect{ d.update }.to raise_error(RuntimeError)
    end
  end

  describe "#update_element" do
    it "should update a task to a project when required" do
      d = Rubyfocus::Document.new
      t = Rubyfocus::Task.new(d, id: "Sample ID")

      node = xml do
        tag :task, op: "update", id: "Sample ID" do
          tag(:project){ tag :folder }
        end
      end

      d.update_element(node)
      expect(d.tasks.size).to eq(0)
      expect(d.projects.size).to eq(1)
    end

    it "should maintain a project as a project when no project tag is provided" do
      d = Rubyfocus::Document.new
      t = Rubyfocus::Project.new(d, id: "Sample ID")

      node = xml do
        tag :task, op: "update", id: "Sample ID" do
          tag(:name){ "Foobar" }
        end
      end

      d.update_element(node)
      expect(d.tasks.size).to eq(0)
      expect(d.projects.size).to eq(1)
    end

    it "should demote a project if an empty <project> tag is spotted" do
      d = Rubyfocus::Document.new
      t = Rubyfocus::Project.new(d, id: "Sample ID")

      node = xml do
        tag :task, op: "update", id: "Sample ID" do
          tag(:project)
        end
      end

      d.update_element(node)
      expect(d.tasks.size).to eq(1)
      expect(d.projects.size).to eq(0)
    end
  end

  describe "#overwrite_element" do
    it "should overwrite an element, removing old properties" do
      d = Rubyfocus::Document.new
      t = Rubyfocus::Task.new(d, id: "Sample task", name: "Foo task", flagged: true)

      node = xml do
        tag :task, op: "update", id: "Sample task" do
          tag(:name){ "New task" }
        end
      end

      d.overwrite_element(node)
      t = d["Sample task"]
      expect(t.name).to eq("New task")
      expect(t.flagged).to eq(false)
    end

    it "should overwrite a task with a project when indicated" do
      d = Rubyfocus::Document.new
      t = Rubyfocus::Task.new(d, id: "Sample ID")

      node = xml do
        tag :task, op: "update", id: "Sample ID" do
          tag(:project){ tag :folder }
        end
      end

      d.overwrite_element(node)
      expect(d.tasks.size).to eq(0)
      expect(d.projects.size).to eq(1)
    end

     it "should demote a project when no project tag is provided" do
      d = Rubyfocus::Document.new
      t = Rubyfocus::Project.new(d, id: "Sample ID")

      node = xml do
        tag :task, op: "update", id: "Sample ID" do
          tag(:name){ "Foobar" }
        end
      end

      d.overwrite_element(node)
      expect(d.tasks.size).to eq(1)
      expect(d.projects.size).to eq(0)
    end
  end
end
