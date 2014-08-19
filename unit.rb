class Unit < Struct.new(:model, :size, :width)
  def dead?
    size <= 0
  end

  def roll_hits(defender)
    if weapon_skill - defender.weapon_skill > 0
      roll_needed = 3
    elsif defender.weapon_skill > (2 * weapon_skill)
      roll_needed = 5
    else
      roll_needed = 4
    end

    roll_dice(model.attacks * size, roll_needed)
  end

  def roll_wounds(hits, defender)
    roll_needed = defender.toughness - strength + 4
    roll_needed = 6 if roll_needed > 6
    roll_needed = 2 if roll_needed < 2

    roll_dice(hits, roll_needed)
  end

  def roll_saves(caused_wounds, attacker_strength)
    save_modifier = attacker_strength > 3 ? attacker_strength - 3 : 0
    roll_needed = armor_save + save_modifier

    caused_wounds - roll_dice(caused_wounds, roll_needed)
  end

  def take_wounds(unsaved_wounds)
    self.size -= unsaved_wounds
  end

  def method_missing(name, *args)
    model.send(name, *args)
  end

  def combat_res_earned
    rank_bonus + banner + wounds_caused + overkill + charge + flank_or_rear
  end

  def rank_bonus
    ranks = size / width + (size % width > 5 ? 1 : 0)
    [ranks - 1, 3].min
  end

  def banner
    0
  end

  def wounds_caused
    @wounds_caused
  end

  def wounds_caused=(new_value)
    @wounds_caused = new_value
  end

  def overkill
    0
  end

  def charge
    0
  end

  def flank_or_rear
    0
  end

  def roll_break_test(modifier)
    result = sum_roll(2)
    if result - modifier <= model.leadership || result == 2
      FALSE
    else
      TRUE
    end
  end

  def roll_pursuit
    sum_roll(2)
  end

  def roll_flee
    sum_roll(2)
  end
end

