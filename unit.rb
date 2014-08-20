require_relative 'compute_hit_needed'
require_relative 'compute_wound_needed'

class Unit < Struct.new(:model, :size, :width, :equipment)
  def dead?
    size <= 0
  end

  def base_attacks
    return 0 if model.attacks == 0
    if is_horde?
      [size, 3 * width].min + (model.attacks - 1) * width
    else
      [size, 2 * width].min + (model.attacks - 1) * width
    end
  end

  def attacks(round_number)
    total_attacks = base_attacks
    equipment.each do |item|
      total_attacks = item.attacks(round_number, total_attacks, self)
    end
    total_attacks
  end

  def models_in_rank(rank_number)
    if size >= rank_number * width
      width
    elsif size >= (rank_number - 1) * width
      size - (rank_number - 1) * width
    else
      0
    end
  end

  def is_horde?
    width >= 10
  end

  def stats(round_number)
    total_stats = model.dup
    equipment.each do |item|
      total_stats = item.stats(round_number, total_stats)
    end
    total_stats
  end

  def hit_needed(round_number, defender)
    roll_needed = ComputeHitNeeded.hit_needed(stats(round_number).weapon_skill, defender.weapon_skill)
    equipment.each do |item|
      roll_needed = item.hit_needed(round_number, roll_needed)
    end
    roll_needed
  end

  def roll_hits(round_number, defender)
    #puts "Attacks: #{attacks} Size: #{size}"
    roll_dice(attacks(round_number), hit_needed(round_number, defender))
  end

  def roll_wounds(round_number, hits, defender)
    roll_needed = ComputeWoundNeeded.wound_needed(stats(round_number).strength, defender.toughness)

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

  def number_of_ranks
    size / width + (size % width > 5 ? 1 : 0)
  end

  def rank_bonus
    [number_of_ranks - 1, 3].min
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

  def roll_break_test(modifier, defender_ranks)
    result = sum_roll(2)
    if is_steadfast?(defender_ranks)
      result > model.leadership && result != 2
    else
      result - modifier > model.leadership && result != 2
    end
  end

  def is_steadfast?(defender_ranks)
    number_of_ranks > defender_ranks
  end

  def roll_pursuit
    sum_roll(2)
  end

  def roll_flee
    sum_roll(2)
  end
end

