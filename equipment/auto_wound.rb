require "equipment/base"

module Equipment
  class AutoWound < Base
    def ==(other)
      other.is_a?(AutoWound)
    end
  end
end

