require_relative 'compute_hit_needed'
require_relative 'compute_wound_needed'

class Unit < Struct.new(:model, :special_models, :size, :width, :offset, :equipment)
  FIRST_RANK = 1

  def for_each_item(&block)
    equipment.each do |item|
      block.call(item)
    end
  end

  def dead?
    size <= 0
  end

  def model_in_position(rank, file)
    found_model = nil
    special_models.each do |position, special_model|
      if model_covers_position?(special_model, position, rank, file)
        found_model = special_model
      end
    end
    found_model || model
  end

  def find_targets(target_unit)
    rank_targets =
      (1..size).map do |model_number|
        rank = ((model_number - 1) / width) + 1
        file = ((model_number - 1) % width) + 1
        model_to_check = model_in_position(rank, file)
        [
          rank,
          target_unit.models_in_mm_range(
            target_unit.convert_coordinate(model.mm_width * (file - 1)),
            target_unit.convert_coordinate(model.mm_width * file)
          ),
        ]
      end
    Hash[rank_targets.group_by { |position_targets|
      position_targets[0]
    }.map { |rank, position_targets|
      [
        rank,
        count_by(position_targets.map { |position_target|
          position_target[1]
        }) { |element| element }
      ]
    }]
  end

  def count_by(array, &block)
    Hash[array.group_by { |element|
      block.call(element)
    }.map { |key, value|
      [key, value.size]
    }]
  end

  def model_covers_position?(special_model, position, rank, file)
    position[1] <= file &&
      file < position[1] + special_model.mm_width / model.mm_width &&
      position[0] <= rank &&
      rank < position[0] + special_model.mm_length / model.mm_length
  end

  def convert_coordinate(value)
    mm_width - value + offset
  end

  def models_in_mm_range(first, second)
    lower, upper = [first, second].sort!
    lower_position = find_position_from_mm(lower, true)
    upper_position = find_position_from_mm(upper, false)
    models = (lower_position..upper_position).map do |position_number|
               model_in_position(FIRST_RANK, position_number)
             end
    models.uniq.sort_by { |model| model.name }
    #Hash[models.group_by { |model| model }.map { |key, value| [key, value.size] }]
  end

  def find_position_from_mm(value, left=false)
    if value % model.mm_width == 0
      position = value / model.mm_width
      [left ? position : position + 1, 1].max
    else
      (value.to_f / model.mm_width).ceil
    end
  end

  def right_flank_location
    left_flank_location + mm_width
  end

  def left_flank_location
    0
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

  def model_count
    size + special_models.size
  end

  def positions_occupied
    size + special_models.inject(0) do |sum, special_model|
      sum +
        special_model[1].mm_width / model.mm_width *
        special_model[1].mm_length / model.mm_length
    end
  end

  def special_model_occupied_spaces_in_rank(rank)
    special_models.inject(0) do |sum, special_model|
      if special_model[0][0] == rank
        sum + special_model[1].mm_width / model.mm_width
      else
        sum
      end
    end
  end

  def farthest_back_special_model_occupied_space
    special_models.map do |position, special_model|
      position[0] + special_model.mm_length / model.mm_length - 1
    end.max || 0
  end

  def number_of_ranks
    final_possible_rank = [positions_occupied / width +
                           (positions_occupied % width >= 1 ? 1 : 0),
                           farthest_back_special_model_occupied_space].max

    final_possible_rank
  end

  def rank_bonus
    remaining_regular_models = size
    rank = 1
    (1..number_of_ranks).each do |current_rank|
      occupied_spaces = special_model_occupied_spaces_in_rank(rank)
      rank = current_rank if remaining_regular_models + occupied_spaces >= 5
      remaining_regular_models -= (width - occupied_spaces)
    end
    [rank - 1, 3].min
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

