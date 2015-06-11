require "set"
require 'inline'

require "unit"
require "rank_list"
require "alignment_strategy"
require "target_finder"
require "target_strategy"

class ConversionHelper
  def self.convert(right, offset, coordinate)
    right + offset - coordinate
  end
end

class MyTest
  inline do |builder|
    builder.c "
    uint upper_file(uint upper_interval, uint right, uint mm_width, uint files) {
      //upper_interval = right - upper_interval;
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
      //lower_interval = right - lower_interval;
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
class RankAndFileUnit < Unit
  attr_reader :positions
  attr_reader :container_unit
  attr_reader :offset
  alias_method :rank_and_file, :container_unit

  def initialize(files, container_unit, container_unit_count, other_units, offset=0)
    super([container_unit, *other_units.values])
    @container_unit             = container_unit
    @size                       = container_unit_count
    @other_units                = other_units
    @files                      = files
    @offset                     = offset
    contained_units.each do |unit|
      unit.unit = self
    end
  end

  def self.new_with_positions(files, container_unit, container_unit_count,
                              other_units, offset=0)
    unit = RankAndFileUnit.new(files, container_unit, container_unit_count,
                               other_units, offset)
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
    @other_units.each(&:destroy)
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

  def selected_intervals
    fighting_ranks = [is_horde? ? 3 : 2, number_of_ranks].min
    fighting_ranks.times.map do |rank|
      @positions.selected_intervals(@container_unit, rank).map do |matching_file|
        [(matching_file - 1) * @container_unit.mm_width,
         matching_file * @container_unit.mm_width]
      end
    end
  end

  def targets_in_intervals(intervals, helper=MyTest.new)
    target_list = nil
    intervals = convert_coordinates(intervals)
    intervals.reduce({}) { |a, interval|
      upper_interval, lower_interval = interval
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
          if a[target_list]
            a[target_list] += 1
          else
            a[target_list] = 1
          end
        end
      end
      a
    }
   #  .map { |target_list, count|
   #  [count, target_list]
   #}.sort!
  end

  def take_wounds(number_of_wounds)
    if @size >= number_of_wounds
      @size -= number_of_wounds
    else
      @size = 0
    end
    @positions.unfill!(@container_unit, number_of_wounds)
  end

  def units_with_initiative(initiative_value, round_number)
    @positions.each_position do |rank, file, unit|
      if unit.initiative(round_number) == initiative_value
        yield rank, file, unit
      end
    end
  end

 #def rank_and_file_matchups(target_unit, round_number)
 #  matchups     = []
 #  intervals    = []
 #  current_rank = 1
 #  @positions.find_each(rank_and_file) do |rank, file, _|
 #    if rank != current_rank
 #      attacks = @container_unit.attacks(round_number, current_rank)
 #      targets = target_unit.targets_in_intervals(intervals)
 #      targets.each do |count, target_list|
 #        target_strategy = TargetStrategy::RankAndFileFirst.new(@container_unit, target_unit)
 #        matchups << AttackMatchup.new(round_number, @container_unit, count * attacks, target_strategy.pick(target_list))
 #      end
 #      intervals = []
 #      current_rank = rank
 #    end
 #    intervals << [(file - 1) * @container_unit.mm_width,
 #                  file * @container_unit.mm_width]
 #  end
 #  attacks = @container_unit.attacks(round_number, current_rank)
 #  targets = target_unit.targets_in_intervals(intervals)
 #  targets.each do |count, target_list|
 #    target_strategy = TargetStrategy::RankAndFileFirst.new(@container_unit, target_unit)
 #    matchups << AttackMatchup.new(round_number, @container_unit, count * attacks, target_strategy.pick(target_list))
 #  end
 #  matchups
 #end

  def rank_and_file_intervals
    intervals = []
    @positions.find_each(rank_and_file) do |rank, file, unit|
      intervals[rank - 1] ||= []
      intervals[rank - 1] << [(file - 1) * @container_unit.mm_width,
                              file * @container_unit.mm_width]
    end
    intervals
  end

  def rank_and_file_matchups(initiative_value, round_number, target_unit)
    return [] unless rank_and_file.initiative(round_number) == initiative_value
    matchups = []
    rank = 0
    final_targets = rank_and_file_intervals.reduce({}) do |targets, rank_intervals|
      rank += 1
      attacks = rank_and_file.attacks(round_number, rank)
      new_targets = target_unit.targets_in_intervals(rank_intervals)
      new_targets = Hash[new_targets.map { |target_list, count| [target_list, count * attacks] }]
      targets.merge(new_targets) do |key, old_val, new_val|
        old_val + new_val
      end
    end
    final_targets.each do |target_list, attacks|
      target_strategy = TargetStrategy::RankAndFileFirst.new(@container_unit, target_unit)
      matchups << AttackMatchup.new(round_number, @container_unit, attacks, target_strategy.pick(target_list))
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
    end
    matchups
  end

  private

  def assign_positions
    return if @size < 0
    @positions = RankList.new(@files, number_of_ranks, CenterAlignStrategy)
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

  def convert_coordinates(coordinate_list)
    coordinate_list.map do |element|
      if element.is_a?(Array)
        element.map! { |coordinate| ConversionHelper.convert(right, offset, coordinate) }
      else
        ConversionHelper.convert(right, offset, coordinate)
      end
    end
  end
end

