# The ReviewPeriod represents a review period used with Projects in OmniFocus
# The ReviewPeriod is made up of three sections:
# * The precursor symbol (~ or @, use unknown)
# * A numerical "size"
# * A unit ([d]ays, [w]eeks, [m]onths or [y]ears)

class Rubyfocus::ReviewPeriod
	attr_accessor :size, :unit

	ALLOWED_UNITS = %i(days weeks months years)

	def self.from_string(str)
		if str =~ /^[@~]?(\d+)([a-z])$/
			size = $1.to_i
			unit = {"d" => :days, "w" => :weeks, "m" => :months, "y" => :years}[$2]
			new(size: size, unit: unit)
		else
			raise ArgumentError, "Unrecognised review period format: \"#{str}\"."
		end
	end

	def initialize(size:0, unit: :months)
		self.size = size
		self.unit = unit
	end

	def unit= value
		raise ArgumentError, "Tried to set ReviewPeriod.unit to invalid value \"#{value}\"." unless ALLOWED_UNITS.include?(value)
		@unit = value
		@short_unit = nil
	end

	def short_unit
		@short_unit ||= @unit.to_s[0]
	end

	def to_s
		"#{size}#{short_unit}"
	end

	alias_method :inspect, :to_s
	alias_method :to_serial, :to_s
end