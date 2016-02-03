class Rubyfocus::Task < Rubyfocus::RankedItem
	include Rubyfocus::Parser
	def self.matches_node?(node)
		return (node.name == "task")
	end
	
	# Inherits from RankedItem:
	# * rank
	# Inherits from NamedItem:
	# * name
	# Inherits from Item:
	# * id
	# * added
	# * modified
	# * document

	attr_accessor :note, :flagged, :order, :start, :due, :completed
	idref :context

	def initialize(document, n=nil)
		@order = :sequential
		@flagged = false
	  super(document,n)
	end

	def apply_xml(n)
		super(n)
		conditional_set(:container_id, n.at_xpath("xmlns:task") || n.at_xpath("xmlns:project/xmlns:folder")){ |e| e["idref"] }

		conditional_set(:context_id, 	n.at_xpath("xmlns:context"))	{ |e| e["idref"] }
		conditional_set(:note, 				n.at_xpath("xmlns:note"))			{ |e| e.inner_html.strip }
		conditional_set(:order, 			n.at_xpath("xmlns:order"))		{ |e| e.inner_html.to_sym }
		conditional_set(:flagged,			n.at_xpath("xmlns:flagged"))	{ |e| e.inner_html == "true" }
		conditional_set(:start, 			n.at_xpath("xmlns:start"))		{ |e| Time.parse(e.inner_html) }
		conditional_set(:due, 		 		n.at_xpath("xmlns:due"))			{ |e| Time.parse(e.inner_html) }
		conditional_set(:completed,		n.at_xpath("xmlns:completed")){ |e| Time.parse(e.inner_html) }
	end

	# Convenience methods
	def completed?; !self.completed.nil?; end
	alias_method :flagged?, :flagged

	# Collect all child tasks. If child tasks have their own subtasks, will instead fetch those.
	def tasks
		@tasks ||= if self.id.nil?
			[]
		else
			t_arr = document.tasks.select(container_id: self.id)
			i = 0
			while i < t_arr.size
				task = t_arr[i]
				if task.has_subtasks?
					t_arr += t_arr.delete_at(i).tasks
				else
					i += 1
				end
			end
			t_arr
		end
	end

	# Collect only immediate tasks: I don't care about this subtasks malarky
	def immediate_tasks
		document.tasks.select(container_id: self.id)
	end

	# The first non-completed task, determined by order
	def next_available_task
		nat_candidate = immediate_tasks.select{ |t| !t.completed? }.sort_by(&:rank).first
		if nat_candidate && nat_candidate.has_subtasks?
			nat_candidate.next_available_task
		else
			nat_candidate
		end
	end

	# A list of all tasks that you can take action on. Actionable tasks
	# are tasks that are:
	# * not completed
	# * not blocked (as part of a sequential project or task group)
	# * not due to start in the future
	def actionable_tasks
		@actionable_tasks ||= next_tasks.select{ |t| !t.deferred? }
	end

	# A list of all tasks that are not blocked.
	def next_tasks
		@next_tasks ||= incomplete_tasks.select{ |t| !t.blocked? }
	end

	# A list of all tasks that aren't complete
	def incomplete_tasks
		@incomplete_tasks ||= tasks.select{ |t| !t.completed? }
	end

	# Are there any tasks on this project which aren't completed?
	def tasks_remain?
		tasks.any?{ |t| t.completed.nil? }
	end

	# Does this task have any subtasks?
	def has_subtasks?
		tasks.size > 0
	end

	# Can we only start this task at some point in the future?
	def deferred?
		start && start > Time.now
	end

	# Can we attack this task, or does its container stop that happening?
	def blocked?
		container && (container.order == :sequential) && (container.next_available_task != self)
	end

	#---------------------------------------
	# Conversion methods

	# Convert the task to a project
	def to_project
		p = Rubyfocus::Project.new(self.document)
		instance_variables.each do |ivar|
			setter = ivar.to_s.gsub(/^@/,"") + "="
			p.send(setter, self.instance_variable_get(ivar))	if p.respond_to?(setter)
		end
		p
	end

	private
	def inspect_properties
		super + %w(note container_id context_id order flagged start due completed)
	end
end