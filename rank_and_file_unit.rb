require 'inline'

require "container_unit"
require "rank_list"
require "rank_and_file_rank_list"
require "alignment_strategy"
require "target_finder"
require "target_strategy"
require "equipment"
require "attack"

class MyTest
  inline do |builder|
    builder.c "
    uint upper_file(uint upper_interval, uint right, uint mm_width, uint files) {
      uint upper = 0;
      if (upper_interval % mm_width == 0) {
        upper = upper_interval / mm_width + 1;
      } else {
        upper = upper_interval / mm_width;
      }
      if (upper > files) {
        return files;
      } else {
        return upper;
      }
    }"
    builder.c "
    uint lower_file(uint lower_interval, uint right, uint mm_width, uint files) {
      int lower = lower_interval / mm_width;
      if (lower > 1) {
        return lower;
      } else {
        return 1;
      }
    }"
    builder.c_raw "
    static VALUE test(int argc, VALUE *argv, VALUE self) {
      ID factorial_method = rb_intern(\"factorial\");
      return rb_funcall(argv[0], factorial_method, 1, INT2FIX(5));
    }"
    builder.c_raw "
    static VALUE get_at_position(int argc, VALUE *argv, VALUE self) {
      ID sym_at = rb_intern(\"at\");
      return rb_funcall(argv[0], sym_at, 2, argv[1], argv[2]);
    }"
  end
end

# This class is a Unit that forms up into rank and files.
#
# offset - the distance in milimeters from the opposing unit's left flank to
#   this unit's right flank. For example, if a unit of 7 wide witch elves was
#   facing off against a 5 wide goblin unit and the goblin unit was centered
#   to the witch elf unit, the offset for witch elf unit would be -20 and the
#   goblin unit would be +20. The negative is because the goblin unit's left
#   flank is left of the witch elf right flank and the positive is because for
#   the goblin's the opposite is true.
class RankAndFileUnit < ContainerUnit
  attr_reader :positions
  attr_reader :container_unit
  attr_reader :offset
  alias_method :rank_and_file, :container_unit

  def initialize(files, container_unit, container_unit_count, other_units, offset=0, equipment=[])
    super([container_unit, *other_units.values])
    @container_unit             = container_unit
    @size                       = container_unit_count
    @other_units                = other_units
    @files                      = files
    @offset                     = offset
    @equipment                  = equipment
    @interval_target_cache      = {}
    @leftover_wounds            = 0
    @equipment.each { |item| item.owner = self }
  end

  def self.new_with_positions(files, container_unit, container_unit_count,
                              other_units, offset=0, equipment=[])
    unit = RankAndFileUnit.new(files, container_unit, container_unit_count,
                               other_units, offset, equipment)
    unit.send(:assign_positions)
    unit
  end

  def dead?
    @other_units.reduce(@size <= 0) do |previous_values, other_unit|
      _position, unit = other_unit
      previous_values && unit.dead?
    end
  end

  def destroy
    @positions.unfill!(@container_unit, @size)
    @size = 0
    @other_units.each { |_, unit| unit.destroy }
  end

  def model_count
    @size + @other_units.size
  end

  def width
    @files
  end

  def mm_width
    @_mm_width ||= width * @container_unit.mm_width
  end
  alias_method :right, :mm_width

  def length
    (occupied_spaces.to_f / @files).ceil
  end
  alias_method :number_of_ranks, :length

  def mm_length
    @_mm_length ||= length * @container_unit.mm_length
  end

  def occupied_spaces
    @size + other_unit_occupied_spaces
  end

  def left
    0
  end

  def is_horde?
    @files >= 10
  end

  def is_rank_and_file?(unit_in_question)
    rank_and_file == unit_in_question
  end

  def targets_in_intervals(intervals, helper=MyTest.new)
    target_list = nil
    intervals.reduce({}) do |a, interval|
      target_list =
        if @interval_target_cache[interval]
          @interval_target_cache[interval]
        else
          @interval_target_cache[interval] = begin
            upper_interval, lower_interval = convert_interval(interval)
            if upper_interval >= 0 && lower_interval <= right
              upper_file = helper.upper_file(upper_interval, right, @container_unit.mm_width, @files)
              lower_file = helper.lower_file(lower_interval, right, @container_unit.mm_width, @files)
              #p "#{interval}:#{right} #{lower_file}..#{upper_file}"
              target_list = (lower_file..upper_file).map do |file|
                @positions.at(file, 1)
              end
              target_list.compact!
              unless target_list.empty?
                target_list.sort!
                target_list.uniq!
              end
              target_list
            else
              []
            end
          end
        end
      unless target_list.empty?
        if a[target_list]
          a[target_list] += 1
        else
          a[target_list] = 1
        end
      end
      a
    end
  end

  def take_wounds(number_of_wounds)
    # puts "beginning size #{@size} of #{@container_unit.name}"
    number_of_wounds += @leftover_wounds
    @leftover_wounds = 0
    if @size * @container_unit.wounds >= number_of_wounds
      @size -= number_of_wounds / @container_unit.wounds
      @leftover_wounds = number_of_wounds % @container_unit.wounds
      call_equipment(:taken_wounds, 1, number_of_wounds)
    else
      @size = 0
      call_equipment(:taken_wounds, 1, @size)
    end
    @positions.unfill!(@container_unit, number_of_wounds / @container_unit.wounds)
    if number_of_ranks <= 1
      @interval_target_cache = {}
    end
    # puts "ending size #{@size} of #{@container_unit.name}"
  end

  def restore_wounds(number_of_wounds)
    if @leftover_wounds >= number_of_wounds
      @leftover_wounds -= number_of_wounds
    else
      models_to_restore = number_of_wounds / @container_unit.wounds
      if number_of_ranks <= 1 && models_to_restore > 0
        @interval_target_cache = {}
      end
      number_of_wounds -= @leftover_wounds
      @size += models_to_restore
      @leftover_wounds = number_of_wounds % @container_unit.wounds
      @positions.fill!(@container_unit, models_to_restore)
    end
  end

  def call_equipment(action_to_call, round_number, starting_value, *args)
    # puts "args: #{action_to_call}, #{round_number}, #{starting_value}, #{args}"
    @equipment.reduce(starting_value) { |a, item| item.send(action_to_call, round_number, a, *args) }
  end

  def call_equipment_hook(hook_to_call, round_number, *args)
    @equipment.each { |item| item.send(hook_to_call, round_number, *args) }
    contained_units.each { |unit| unit.call_equipment_hook(hook_to_call, round_number, *args) }
  end

  def remove_equipment(item)
    @equipment -= [item]
  end

  def rank_and_file_intervals
    intervals = []
    @positions.find_each(rank_and_file) do |rank, file, unit|
      intervals[rank - 1] ||= []
      intervals[rank - 1] << [(file - 1) * @container_unit.mm_width,
                              file * @container_unit.mm_width]
    end
    intervals
  end

  def build_matchups(round_number, initiative_value, target_unit)
    (other_unit_model_intervals(round_number, initiative_value) + rank_and_file_model_intervals(round_number, initiative_value)).map do |lower_interval, upper_interval, attacks|
      if !attacks.empty? && (target = pick_target([lower_interval, upper_interval], target_unit))
        [target, attacks]
      else
        next
      end
    end.compact.group_by do |element|
      element[0]
    end.map do |(target, grouped_by_array)|
      attacks = grouped_by_array.flat_map { |target, attack| attack }
      [target, Attack.join(attacks)]
    end.flat_map do |target, attacks|
      attacks.map { |attack| AttackMatchup.new(round_number, attack, target) }
    end
  end

  def pick_target(interval, target_unit)
    targets = target_unit.targets_in_intervals([interval])
    target_list, count = targets.first
    # puts "target_list: #{target_list}"
    if target_list
      target_strategy = TargetStrategy::RankAndFileFirst.new(@container_unit, target_unit)
      target_strategy.pick(target_list)
    else
      nil
    end
  end

  def other_unit_model_intervals(round_number, initiative_value)
    @other_units.map do |(rank, file), other_unit|
      attacks = other_unit.attacks(round_number, initiative_value, rank)
      [*compute_interval(file, other_unit.mm_width), attacks]
    end
  end

  def rank_and_file_model_intervals(round_number, initiative_value)
    @positions.find_each(rank_and_file).map do |rank, file, unit|
      attacks = unit.attacks(round_number, initiative_value, rank)
      [*compute_interval(file, @container_unit.mm_width), attacks]
    end
  end

  def all_model_intervals(round_number, initiative_value, target_unit)
    @positions.each_model.map do |rank, file, unit|
      attacks = unit.attacks(round_number, initiative_value, rank)
      lower_interval, upper_interval = compute_interval(file, unit.mm_width)
      if !attacks.empty? && (target = pick_target([lower_interval, upper_interval], target_unit))
        [target, attacks]
      else
        next
      end
    end.compact
  end

  def build_matchups2(round_number, initiative_value, target_unit)
    group_attacks(round_number, all_model_intervals(round_number, initiative_value, target_unit))
  end

  def group_attacks(round_number, targets_with_attacks)
    targets_with_attacks.group_by do |element|
      element[0]
    end.map do |(target, grouped_by_array)|
      attacks = grouped_by_array.flat_map { |target, attack| attack }
      [target, Attack.join(attacks)]
    end.flat_map do |target, attacks|
      attacks.map { |attack| AttackMatchup.new(round_number, attack, target) }
    end
  end

  def compute_interval(file, model_width)
    lower = (file - 1) * @container_unit.mm_width
    [lower, lower + model_width]
  end

  def rank_and_file_matchups(initiative_value, round_number, target_unit)
    matchups = []
    if rank_and_file.initiative(round_number) == initiative_value
      rank = 0
      final_targets = rank_and_file_intervals.reduce({}) do |targets, rank_intervals|
        rank += 1
        # attacks = rank_and_file.attacks(round_number, rank)
        new_targets = target_unit.targets_in_intervals(rank_intervals)
        new_targets = Hash[new_targets.map do |target_list, count|
                             attacks = (1..count).reduce(0) do |attack_sum, index|
                               attack_sum + rank_and_file.attacks(round_number, rank)
                             end
                             [target_list, attacks]
                           end]
        targets.merge(new_targets) do |key, old_val, new_val|
          old_val + new_val
        end
      end
      final_targets.each do |target_list, attacks|
        target_strategy = TargetStrategy::RankAndFileFirst.new(@container_unit, target_unit)
        matchups << AttackMatchup.new(round_number, @container_unit, attacks, target_strategy.pick(target_list))
      end
    end
    rank = 0
    final_targets = rank_and_file_intervals.reduce({}) do |targets, rank_intervals|
      rank += 1
      # attacks = rank_and_file.attacks(round_number, rank)
      new_targets = target_unit.targets_in_intervals(rank_intervals)
      new_targets = Hash[new_targets.map do |target_list, count|
                           attacks = (1..count).reduce(0) do |attack_sum, index|
                             attack_sum + 1
                           end
                           [target_list, attacks]
                         end]
      targets.merge(new_targets) do |key, old_val, new_val|
        old_val + new_val
      end
    end
    final_targets.each do |target_list, attacks|
      target_strategy = TargetStrategy::RankAndFileFirst.new(@container_unit, target_unit)
      matchups = rank_and_file.call_equipment(:matchups_for_initiative, round_number, matchups, initiative_value, attacks, target_strategy.pick(target_list))
    end
    matchups
  end

  def matchups_for_initiative(initiative_value, round_number, target_unit)
    other_unit_matchups(initiative_value, round_number, target_unit) +
      rank_and_file_matchups(initiative_value, round_number, target_unit)
  end

  def other_unit_matchups(initiative_value, round_number, target_unit)
    matchups = []
    @other_units.each do |position, unit|
      rank, file = position
      if unit.initiative(round_number) == initiative_value &&
          unit.attacks(round_number, rank) > 0
        interval = [[(file - 1) * @container_unit.mm_width,
                     (file - 1 + unit.mm_width / @container_unit.mm_width) * @container_unit.mm_width]]
        targets = target_unit.targets_in_intervals(interval)
        targets.each do |target_list, count|
          target_strategy = TargetStrategy::RankAndFileFirst.new(unit, target_unit)
          matchups << AttackMatchup.new(round_number, unit,
                                        unit.attacks(round_number, rank),
                                        target_strategy.pick(target_list))
        end
      end
      matchups = unit.call_equipment(:matchups_for_initiative, round_number, matchups, initiative_value, target_unit)
    end
    matchups
  end

  def has_standard?
    @size > 0 && @equipment.include?(Equipment::Standard.new)
  end

  def lose_standard_bearer
    if has_standard?
      @size -= 1
      @equipment -= [Equipment::Standard.new]
    end
  end

  def other_unit_died(unit)
    @positions.unfill!(unit, 1)
    @other_units.delete_if { |_, other_unit| other_unit == unit }
  end

  def initiative_steps(round_number)
    call_equipment(:initiative_steps, round_number, super(round_number))
  end

  private

  def assign_positions
    return if @size < 0
    @positions = RankAndFileRankList.new(RankList.new(@files, number_of_ranks, AlignmentStrategy::Center), rank_and_file)
    assign_other_units
    @positions.fill!(@container_unit, @size)
  end

  def assign_other_units
    @other_units.each do |position, unit|
      rank, file = position
      occupied_files, occupied_ranks = compute_occupation(unit)
      (0...occupied_ranks).each do |rank_index|
        (0...occupied_files).each do |file_index|
          @positions.set(file + file_index, rank + rank_index, unit)
        end
      end
    end
  end

  def other_unit_occupied_spaces
    @_other_unit_occupied_spaces ||= @other_units.reduce(0) do |sum, other_unit|
      _positions, unit = other_unit
      occupied_files, occupied_ranks = compute_occupation(unit)
      sum + occupied_ranks * occupied_files
    end
  end

  # Returns [occupied_files, occupied_ranks]
  def compute_occupation(unit)
    [
      unit.mm_width / @container_unit.mm_width,
      unit.mm_length / @container_unit.mm_length
    ]
  end

  def convert_interval(interval)
    interval.map { |coordinate| right + offset - coordinate }
  end

  def convert_coordinates(coordinate_list)
    coordinate_list.map! do |element|
      element.map! { |coordinate|
        right + offset - coordinate
      }
    end
  end
end
