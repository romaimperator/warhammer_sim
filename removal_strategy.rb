class RemovalStrategy
  def self.remove_one(last_rank, value_to_remove)
    fail NotYetImplemented
  end
end

class EqualRemovalStrategy < RemovalStrategy
  def self.remove_one(last_rank, value_to_remove)
    left_empty_spots = last_rank.take_while { |value| value == nil }.size
    right_empty_spots = last_rank.reverse.take_while { |value| value == nil }.size
    if left_empty_spots > right_empty_spots
    end
  end
end

