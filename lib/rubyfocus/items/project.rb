# The project represents an OmniFocus project object.
class Rubyfocus::Project < Rubyfocus::Task
	# It's parseable
	include Rubyfocus::Parser

	#-------------------------------------------------------------------------------
	# Parsing stuff

	# Projects are <task>s with an interior <project> node
	def self.matches_node?(node)
		return (node.name == "task" && (node/"project").size > 0)
	end
	
	# Singleton: contains one-off tasks
	attr_accessor :singleton

	# How often to we review this project?
	attr_accessor :review_interval

	# When did we last review the project?
	attr_accessor :last_review

	# How do tasks become available? By default, projects are :sequential, but they can
	# also be :parallel
	attr_accessor :order

	# What's the status of the project? Valid options: :active, :inactive, :done. Default
	# is :active
	attr_accessor :status

	# Initialize the project with a document and optional node to base it off of.
	# Also sets default values
	def initialize(document=nil, n=nil)
		@singleton = false
		@order = :sequential
		@status = :active
		super(document, n)
	end

	# Apply XML node to project
	def apply_xml(n)
		super(n)

		#First, set project
		p = n.at_xpath("xmlns:project")
		conditional_set(:singleton, 			p.at_xpath("xmlns:singleton"))					{ |e| e.inner_html == "true" }
		conditional_set(:review_interval, p.at_xpath("xmlns:review-interval") ) 	{ |e| Rubyfocus::ReviewPeriod.from_string(e.inner_html) }
		conditional_set(:last_review, 		p.at_xpath("xmlns:last-review"))				{ |e| Time.parse e.inner_html }
		conditional_set(:status,					p.at_xpath("xmlns:status"))							{ |e| e.inner_html.to_sym }							
	end

	alias_method :singleton?, :singleton

	private
	def inspect_properties
		super + %w(singleton review_interval last_review)
	end

	public

	#-------------------------------------------------------------------------------
	# Convenience methods

	# Status methods
	def active?; status == :active; end
	def on_hold?; status == :inactive; end
	def completed?; status == :done; end
	def dropped?; status == :dropped; end

end