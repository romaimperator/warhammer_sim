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
    [initiative(round_number)]
  end

  def take_wounds(wounds_caused)
    @stats.wounds -= wounds_caused
    if dead? && parent_unit
      parent_unit.other_unit_died(self)
    end
  end

  def weapon_skill(round_number)
    item_manipulation(round_number, :weapon_skill, @stats.weapon_skill)
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
      item_manipulation(round_number, :attacks, @stats.attacks, parent_unit, rank)
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
end

