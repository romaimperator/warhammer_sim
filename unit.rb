require_relative 'compute_hit_needed'
require_relative 'compute_wound_needed'

class Unit < Struct.new(:model, :size, :width, :equipment)
  def for_each_item(&block)
    equipment.each do |item|
      block.call(item)
    end
  end

  def dead?
    size <= 0
  end

  def models_in_base_contact(defender)
    if mm_width > defender.mm_width
      defender.mm_width / model.mm_width + 2
    elsif mm_width < defender.mm_width
      width
    else
      width
    end
  end

  def mm_width
    width * model.mm_width
  end

  def base_attacks(defender)
    return 0 if model.attacks == 0
    if is_horde?
      [size, 3 * models_in_base_contact(defender)].min + (model.attacks - 1) * models_in_base_contact(defender)
    else
      [size, 2 * models_in_base_contact(defender)].min + (model.attacks - 1) * models_in_base_contact(defender)
    end
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

  def take_wounds(unsaved_wounds)
    self.size = [self.size - unsaved_wounds, 0].max
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
    @wounds_caused ||= 0
  end

  def wounds_caused=(new_value)
    @wounds_caused = new_value
  end

  def hits
    @hits||= 0
  end

  def hits=(new_value)
    @hits= new_value
  end

  def unsaved_wounds
    @unsaved_wounds ||= 0
  end

  def unsaved_wounds=(new_value)
    @unsaved_wounds = new_value
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

