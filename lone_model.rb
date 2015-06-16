require "model"
require "stats"

class LoneModel < Model
  def initialize(*args, stats, &block)
    super(*args, &block)
    @stats = stats
    @manipulations_store = {}
  end

  def attack_stats(round_number)
    cache_fetch(round_number, :attack_stats) do
      AttackStats.new(
        weapon_skill(round_number),
        strength(round_number),
        #attacks(round_number, rank),
      )
    end
  end

  def defend_stats(round_number)
    cache_fetch(round_number, :defend_stats) do
      DefendStats.new(
        weapon_skill(round_number),
        toughness(round_number),
        armor_save(round_number),
        ward_save(round_number),
      )
    end
  end

  def dead?
    wounds <= 0
  end

  def destroy
    take_wounds(wounds)
  end

  def initiative_steps(round_number)
    call_equipment(:initiative_steps, round_number, [initiative(round_number)])
  end

  def take_wounds(wounds_caused)
    @stats.wounds -= wounds_caused
    if dead? && parent_unit
      parent_unit.other_unit_died(self)
    end
  end

  def targets_in_intervals(intervals)
    intervals.reduce({}) do |a, interval|
      upper_interval, lower_interval = convert_interval(interval)
      if upper_interval >= left && lower_interval <= right
        if a[self]
          a[self] += 1
        else
          a[self] = 1
        end
      end
      a
    end
  end

  def matchups_for_initiative(initiative_value, round_number, target_unit)
    matchups = []
    if initiative(round_number) == initiative_value &&
       attacks(round_number, 1) > 0
      interval = [[left, right]]
      target_list, count  = *target_unit.targets_in_intervals(interval)
      target_strategy = TargetStrategy::RankAndFileFirst.new(self, target_unit)
      matchups << AttackMatchup.new(round_number, self, attacks(round_number, 1), 
                                    target_strategy.pick(target_list))
    end
    interval = [[left, right]]
    target_list, count  = *target_unit.targets_in_intervals(interval)
    target_strategy = TargetStrategy::RankAndFileFirst.new(self, target_unit)
    matchups = call_equipment(:matchups_for_initiative, round_number, initiative_value, 1,
                                  target_strategy.pick(target_list))
  end

  def weapon_skill(round_number)
    # item_manipulation(round_number, :weapon_skill, @stats.weapon_skill)
    equipment.reduce(@stats.weapon_skill) do |result, item|
      item.send(:weapon_skill, round_number, result)
    end
  end

  def strength(round_number)
    item_manipulation(round_number, :strength, @stats.strength)
  end

  def toughness(round_number)
    item_manipulation(round_number, :toughness, @stats.toughness)
  end

  def wounds
    item_manipulation(1, :wounds, @stats.wounds)
  end

  def initiative(round_number)
    item_manipulation(round_number, :initiative, @stats.initiative)
  end

  def attacks(round_number, rank)
    if rank == 1
      # item_manipulation(round_number, :attacks, @stats.attacks, parent_unit, rank)
      equipment.reduce(@stats.attacks) do |result, item|
        item.send(:attacks, round_number, result, parent_unit, rank)
      end
    elsif rank == 2 || (rank == 3 && parent_unit.is_horde?)
      1
    else
      0
    end
  end

  def leadership
    item_manipulation(1, :leadership, @stats.leadership)
  end

  def armor_save(round_number)
    item_manipulation(round_number, :armor_save, @stats.armor_save)
  end

  def ward_save(round_number)
    item_manipulation(round_number, :ward_save, @stats.ward_save)
  end

  def hit_reroll_values(to_hit_number)
    reroll_values = item_manipulation(1, :hit_reroll_values, [], to_hit_number)
    reroll_values.uniq
  end

  def wound_reroll_values(to_wound_number)
    reroll_values = item_manipulation(1, :wound_reroll_values, [], to_wound_number)
    reroll_values.uniq
  end

  private

  def item_manipulation(round_number, method_name, starting_value, *args)
    cache_fetch(round_number, [method_name, *args]) do
      equipment.reduce(starting_value) do |result, item|
        item.send(method_name, round_number, result, *args)
      end
    end
  end

  def cache_fetch(round_number, cache_key)
    unless @manipulations_store[round_number]
      @manipulations_store[round_number] = {}
    end
    @manipulations_store[round_number][cache_key] ||= yield
  end

  def convert_interval(interval)
    interval.map { |coordinate| right + offset - interval }
  end
end

