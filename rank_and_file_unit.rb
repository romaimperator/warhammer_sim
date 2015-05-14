require_relative 'unit'
require_relative 'rank_list'
require_relative 'alignment_strategy'

class RankAndFileUnit < Unit
  def initialize(files, container_unit, container_unit_count, other_units)
    super([container_unit, *other_units])
    @container_unit             = container_unit
    @size                       = container_unit_count
    @other_units                = other_units
    @files                      = files
    assign_positions
  end

  def dead?
    @other_units.reduce(@size <= 0) do |previous_values, other_unit|
      position, unit = other_unit
      previous_values && unit.dead?
    end
  end

  def model_count
    @size + @other_units.keys.size
  end

  def width
    @files
  end

  def mm_width
    width * @container_unit.mm_width
  end

  def length
    number_of_ranks
  end

  def mm_length
    length * @container_unit.mm_length
  end

  def number_of_ranks
    (occupied_spaces.to_f / @files).ceil
  end

  def occupied_spaces
    @size + other_unit_occupied_spaces
  end

  def inspect
    @positions.inspect
  end

private

  def assign_positions
    return if @size <= 0
    #@positions = Array.new(number_of_ranks) { Array.new(@files) { @container_unit } }
    @positions = RankList.new(@files, number_of_ranks)
    assign_other_units
    @positions.fill!(@container_unit, @size)
    #fix_rear_rank
  end

  def assign_other_units
    @other_units.each do |position, unit|
      rank, file = position
      occupied_files = unit.mm_width / @container_unit.mm_width
      occupied_ranks = unit.mm_length / @container_unit.mm_length
      (0...occupied_ranks).each do |rank_index|
        (0...occupied_files).each do |file_index|
          #@positions[rank - 1 + rank_index][file - 1 + file_index] = unit
          @positions.set(file + file_index, rank + rank_index, unit)
        end
      end
    end
  end

  def other_unit_occupied_spaces
    @_other_unit_occupied_spaces ||= @other_units.reduce(0) do |sum, other_unit|
      positions, unit = other_unit
      occupied_files = unit.mm_width / @container_unit.mm_width
      occupied_ranks = unit.mm_length / @container_unit.mm_length
      occupied_ranks * occupied_files
    end
  end

  def align_rear_rank
    @positions[number_of_ranks] = CenterAlignStrategy.align_rank(@positions[number_of_ranks], empty_rear_rank_spaces)
  end

  def fix_rear_rank
    if occupied_rear_rank_spaces > 0
      @positions[number_of_ranks] = build_new_rank(occupied_rear_rank_spaces)
      align_rear_rank
    end
  end

  def build_new_rank(occupied_spaces)
    [@container_unit] * occupied_spaces + blank_spaces(@files - occupied_spaces)
  end

  def occupied_rear_rank_spaces
    model_count % @files
  end

  def empty_rear_rank_spaces
    @files - occupied_rear_rank_spaces
  end

  def blank_spaces(count)
    [nil] * count
  end
end

