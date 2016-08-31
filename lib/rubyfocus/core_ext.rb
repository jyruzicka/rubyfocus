class Time
  # Will return nil if +val+ is nil or a blank string.
  # Otherwise, will parse as normal using Time.parse
  def self.safely_parse(val)
    if val.nil? || val == ""
      nil
    else
      parse(val)
    end
  end
end