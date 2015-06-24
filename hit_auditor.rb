require "auditor"

class HitAuditor < Auditor
  def mappings(method_name)
    @mappings ||= {
      rolls:         :roll_hits,
      value_needed:  :hit_needed,
      reroll_values: :hit_reroll_values,
    }
    @mappings.fetch(method_name)
  end
end

