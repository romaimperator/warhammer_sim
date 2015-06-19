require "equipment/base"

module Equipment
  class Standard < Base
    # All standards are equal since we only need to check for presence
    def ==(other)
      other.is_a?(Standard)
    end
  end
end

