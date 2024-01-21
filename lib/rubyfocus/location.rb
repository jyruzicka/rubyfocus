# A location file. Really a collection of properties and initializer.
class Rubyfocus::Location
  attr_accessor :name, :latitude, :longitude, :radius, :notification_flags

  def initialize(n)
    @notification_flags = 0
    self.name = n["name"]
    self.latitude = n["latitude"].to_f
    self.longitude = n["longitude"].to_f
    self.radius = n["radius"].to_i
    self.notification_flags = n["notificationFlags"].to_i
  end

  def inspect
    %|#<Rubyfocus::Location latitude="#{self.latitude}" longitude="#{self.longitude}">|
  end
end
