require_relative 'unit'

class StandardUnit < Unit
  FIRST_RANK = 1
  INSANE_COURAGE_ROLL = 2

  attr_accessor :round_number
  attr_accessor :model
  attr_accessor :special_models
  attr_accessor :size
  attr_accessor :width
  attr_accessor :offset
  attr_accessor :equipment

  def initialize(model, special_models, size, width, offset, equipment)
    super([model, *special_models])
    self.model = model
    self.special_models = special_models
    self.size = size
    self.width = width
    self.offset = offset
    self.equipment = equipment
    @hits = 0
    @unsaved_wounds = 0
    @wounds_caused = 0
    @manipulations_store = {}
    model.add_equipment(equipment)
    model.unit = self
    special_models.each do |position, special_model|
      special_model.add_equipment(equipment)
      special_model.unit = self
    end
  end

  def get_all_parts
    model.parts + special_models.values.reduce([]) { |part_array, special_model| part_array + special_model.parts }
  end

  def get_matchups(target_unit)
    ranks_that_can_attack = is_horde? ? 3 : 2
    (1..ranks_that_can_attack).map do |rank_number|
      (1..width).map do |file|
        possible_targets = find_targets_for_position(target_unit, rank_number, file)
        current_model = model_in_position(rank_number, file)
        current_model.parts.map do |part|
          selected_target = possible_targets[0] # Put strategy for selecting targets here
          AttackMatchup.new(round_number, part, selected_target)
        end
      end
    end.flatten.flatten.flatten
  end

  def banner
    0
  end

  def charge
    0
  end

  def check_break_test(roll, modifier)
    roll == INSANE_COURAGE_ROLL || !check_leadership_test(roll, modifier)
  end

  def check_leadership_test(roll, modifier)
    roll <= model.leadership + modifier
  end

  def combat_res_earned(round_result)
    rank_bonus + banner + round_result.wounds_caused + overkill + charge + flank_or_rear
  end

  def convert_coordinate(value)
    mm_width - value + offset
  end

  def dead?
    size <= 0
  end

  def farthest_back_special_model_occupied_space
    special_models.map do |position, special_model|
      position[0] + special_model.mm_length / model.mm_length - 1
    end.max || 0
  end

  def find_targets(target_unit)
    rank_targets =
      (1..number_of_ranks).map do |rank|
        (1..width).map do |file|
          find_targets_for_position(target_unit, rank, file)
        end
      end
    rank_targets.map { |rank_positions|
      count_by(rank_positions) { |position| position }
    }
    #Hash[rank_targets.group_by { |position_targets|
    #  position_targets[0]
    #}.map { |rank, position_targets|
    #  [
    #    rank,
    #    count_by(position_targets.map { |position_target|
    #      position_target[1]
    #    }) { |element| element }
    #  ]
    #}]
  end

  def find_targets_for_position(target_unit, rank, file)
    model_to_check = model_in_position(rank, file)
    if !model_to_check.nil?
      target_unit.models_in_mm_range(
        target_unit.convert_coordinate(model.mm_width * (file - 1)),
        target_unit.convert_coordinate(model.mm_width * file)
      ).map { |model| model.parts }.flatten
    else
      []
    end
  end

  def flank_or_rear
    0
  end

  def for_each_item(&block)
    equipment.each do |item|
      block.call(item)
    end
  end

  def has_special_model?(special_model)
    special_models.include?(special_model)
  end

  def hit_reroll_values(round_number, to_hit_number)
    reroll_values = item_manipulation(:hit_reroll_values, round_number, [],
                                      to_hit_number)
    reroll_values.uniq
  end

  def is_horde?
    width >= 10 &&
      size + special_model_occupied_spaces_in_rank(FIRST_RANK) >= 10
  end

  def is_steadfast?(defender_ranks)
    number_of_ranks > defender_ranks
  end

  def item_manipulation(method_name, round_number, starting_value, *args)
    compute_value_block = Proc.new {
      result = starting_value
      for_each_item { |item| result = item.send(method_name, round_number, result, *args) }
      result
    }
    if !@manipulations_store[method_name]
      @manipulations_store[method_name] = {}
    end
    @manipulations_store[method_name][round_number] ||= compute_value_block.call
  end

  def left_flank_location
    0
  end

  def method_missing(name, *args)
    model.send(name, *args)
  end

  def mm_width
    width * model.mm_width
  end

  def model_count
    size + special_models.size
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

  def models_in_mm_range(first, second)
    lower, upper = [first, second].sort!
    lower_position = find_position_from_mm(lower, true)
    upper_position = find_position_from_mm(upper, false)
    models =
      (lower_position..upper_position).map do |position_number|
        model_in_position(FIRST_RANK, position_number)
      end
    models.uniq.sort_by { |model| model.name }
    #Hash[models.group_by { |model| model }.map { |key, value| [key, value.size] }]
  end

  def number_of_attacks(round_number, defender)
    item_manipulation(:attacks, round_number, width * stats(round_number).attacks, self)
  end

  def number_of_ranks
    final_possible_rank = [positions_occupied / width +
                           (positions_occupied % width >= 1 ? 1 : 0),
                           farthest_back_special_model_occupied_space].max

    final_possible_rank
  end

  def notify_model_died(model_that_died)
    if model_that_died == model
      self.size = [self.size - 1, 0].max
    elsif has_special_model?(model_that_died)
      remove_special_model(model_that_died)
    else
      raise Exception.new("Model not found in unit")
    end
  end

  def overkill
    0
  end

  def positions_occupied
    size + special_models.inject(0) do |sum, special_model|
      sum +
        special_model[1].mm_width / model.mm_width *
        special_model[1].mm_length / model.mm_length
    end
  end

  def rank_bonus
    remaining_regular_models = size
    rank = 1
    (1..number_of_ranks).each do |current_rank|
      occupied_spaces = special_model_occupied_spaces_in_rank(current_rank)
      rank = current_rank if remaining_regular_models + occupied_spaces >= 5
      remaining_regular_models -= (width - occupied_spaces)
    end
    [rank - 1, 3].min
  end

  def remove_special_model(model_to_remove)
    special_models -= [model_to_remove]
  end

  def right_flank_location
    left_flank_location + mm_width
  end

  def roll_break_test(modifier, defender_ranks)
    result = sum_roll(2)
    if is_steadfast?(defender_ranks)
      check_break_test(result, 0)
    else
      check_break_test(result, modifier)
    end
  end

  def roll_flee
    sum_roll(2)
  end

  def roll_pursuit
    sum_roll(2)
  end

  def special_model_occupied_spaces_in_rank(rank)
    special_models.inject(0) do |sum, special_model|
      if special_model[0][0] == rank
        sum + special_model[1].mm_width / model.mm_width
      elsif special_model[0][0] + special_model[1].mm_length / model.mm_length - 1 == rank
        sum + special_model[1].mm_width / model.mm_width
      else
        sum
      end
    end
  end

  def stats(round_number)
    item_manipulation(:stats, round_number, model)
  end

  def strength(round_number)
    item_manipulation(:strength, round_number, stats(round_number).strength)
  end

  def take_wounds(unsaved_wounds)
    self.size = [self.size - unsaved_wounds, 0].max
  end

  def wound_reroll_values(round_number, to_wound_number)
    reroll_values = item_manipulation(:wound_reroll_values, round_number, [],
                                      to_wound_number)
    reroll_values.uniq
  end

  def draw
    (1..number_of_ranks).map do |rank|
      (1..width).map do |file|
        model_in_position(rank, file).draw
      end.reduce(["", "", "", ""]) do |sum, drawn_model|
        enum = drawn_model.each
        sum.map do |row|
          row + enum.next
        end
      end
    end
  end

private

  def count_by(array, &block)
    Hash[array.group_by { |element|
      block.call(element)
    }.map { |key, value|
      [key, value.size]
    }]
  end

  def find_position_from_mm(value, left=false)
    if value % model.mm_width == 0
      position = value / model.mm_width
      [left ? position : position + 1, 1].max
    else
      (value.to_f / model.mm_width).ceil
    end
  end

  def model_covers_position?(special_model, position, rank, file)
    position[1] <= file &&
      file < position[1] + special_model.mm_width / model.mm_width &&
      position[0] <= rank &&
      rank < position[0] + special_model.mm_length / model.mm_length
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
end

