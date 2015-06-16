# This is the base class for all equipment. The given method definitions do not
# modify anything which allows for only the methods that need to be overriden
# to require doing so.
module Equipment
  class Base
    # Any class that contains equipment must initialize this attribute so that
    # it may be used by the equipment when needed
    attr_accessor :owner
    
    # Runs at the beginning of a round of combat to be able to do things at that
    # time such as take a fear test. Unlike the other methods, this is a pure
    # event listener and its return value does not matter.
    #
    # unit - the root unit containing this equipment or containing a unit containing
    #        this equipment
    # target_unit - the opposing root unit
    #
    # returns - nothing
    def before_combat(_round_number, _unit, _target_unit)
      # noop
    end

    # Runs first thing after it has been determined that the unit has lost the
    # current round of combat.
    #
    # unit - the unit this piece of equipment is in
    #
    # returns - nothing
    def combat_round_lost(_round_number, _unit)
      # noop
    end
    
    # Given the current round number and the to hit roll (value of 4 means 4+ to
    # hit), this method returns a modified to hit roll.
    # Example usage: adding +1 to hit
    def hit_needed(_round_number, roll_needed)
      roll_needed
    end

    # Given the current round number and the to wound roll (value of 4 means 4+ to
    # wound), this method returns a modified to wound roll.
    # Example usage: adding +1 to wound
    def wound_needed(_round_number, roll_needed)
      roll_needed
    end

    # Given the current round number and the to hit roll (value of 4 means 4+ to
    # hit), this method returns an array of numbers to reroll if any dice equal a
    # number in the array.
    # Example usage: reroll misses by returning [1...hit_needed] (... is
    #   non-inclusive end so result is [1, 2, 3] if hit_needed is 4.
    def hit_reroll_values(_round_number, reroll_values, _hit_needed)
      reroll_values
    end

    # Given the current round number and the to wound roll (value of 4 means 4+ to
    # wound), this method returns an array of numbers to reroll if any dice equal
    # a number in the array.
    # Example usage: reroll failed wounds by returning [1...hit_needed] (... is
    #   non-inclusive end so result is [1, 2, 3] if wound_needed is 4.
    def wound_reroll_values(_round_number, reroll_values, _wound_needed)
      reroll_values
    end

    # Given the current round number and the results of the hit dice rolls, this
    # method returns an array of dice results of hitting.
    # Example usage: implement poison hits by finding 6s
    # (see equipment/poison_attacks.rb for more)
    def roll_hits(_round_number, rolls)
      rolls
    end

    # Given the current round number and the results of the wound dice rolls, this
    # method returns an array of dice results of wounding.
    # Example usage: implement killing blow hits by finding 6s
    def roll_wounds(_round_number, rolls)
      rolls
    end

    def weapon_skill(_round_number, current_weapon_skill)
      current_weapon_skill
    end

    # Given the current round number, the strength of the unit, and the unit
    # itself, this method returns a modified strength.
    # Example usage: adding +1 strength in the first round of combat for a mounted
    # spearman.
    def strength(_round_number, current_strength)
      current_strength
    end

    def toughness(_round_number, current_toughness)
      current_toughness
    end

    def wounds(_round_number, current_wounds)
      current_wounds
    end

    def initiative(_round_number, current_initiative)
      current_initiative
    end

    # Given the current round number, the number of attacks the unit has, the unit
    # itself, and the rank this model is currently in, this method returns a
    # modified number of attacks.
    # Example usage: adding an extra rank of attacks for foot spearmen.
    def attacks(_round_number, current_attacks, _unit, _rank)
      current_attacks
    end

    def leadership(_round_number, current_leadership)
      current_leadership
    end

    def armor_save(_round_number, current_armor_save)
      current_armor_save
    end

    def ward_save(_round_number, current_ward_save)
      current_ward_save
    end

    def roll_break_test(_round_number, current_break_test_roll, _modifier)
      current_break_test_roll
    end

    def check_break_test(_round_number, current_break_test_result, break_test_roll, _modfier, _unit)
      current_break_test_result
    end

    def taken_wounds(_round_number, current_wounds_taken)
      current_wounds_taken
    end

    # Since initiative_steps are a unique array of values, to add a value to the list
    # the | must be used
    # Example: current_initiative_steps | [5]
    def initiative_steps(_round_number, current_initiative_steps)
      current_initiative_steps
    end

    def matchups_for_initiative(_round_number, current_matchups, initiative_value, attacks, picked_target)
      current_matchups
    end
  end
end
