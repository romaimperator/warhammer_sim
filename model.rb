# This class represents a single model in the simulation. It tracks equipment,
# the size, etc.
Model = Struct.new(:name, :mm_width, :mm_length, :equipment) do
  include Comparable
  attr_accessor :parent_unit

  def to_s
    name
  end

  def inspect
    name
  end

  def attack_stats(round_number)
    fail NotYetImplemented
  end

  def defend_stats(round_number)
    fail NotYetImplemented
  end

  def dead?
    fail NotYetImplemented
  end

  def destroy
    fail NotYetImplemented
  end

  def initiative_steps(round_number)
    fail NotYetImplemented
  end

  def take_wounds(wounds_caused)
    fail NotYetImplemented
  end

  def hash
    @hash ||= name.hash
  end

  def ==(other)
    return false unless other.kind_of?(Model)
    name == other.name
  end

  def <=>(other)
    name <=> other.name
  end

end

