require "auditor"

class WoundAuditor < Auditor
  def mappings(method_name)
    @mappings ||= {
      rolls:         :roll_wounds,
      value_needed:  :wound_needed,
      reroll_values: :wound_reroll_values,
    }
    @mappings.fetch(method_name)
  end
end

