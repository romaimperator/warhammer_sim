require "equipment/base"

module Equipment
  class Halberd < Base
    def strength(round_number, current_strength)
      current_strength + 1
    end
  end
end

