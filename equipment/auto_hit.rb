require "equipment/base"

module Equipment
  class AutoHit < Base
    def ==(other)
      other.is_a?(AutoHit)
    end
  end
end
