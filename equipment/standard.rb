require "equipment/base"

module Equipment
  class Standard < Base
    def ==(other)
      other.is_a?(Standard)
    end
  end
end

