require "spec_helper"
require_relative "../rank"

describe Rank do
  describe "#[]" do
    it "allows accessing values with 1 base index" do
      assert_equal 1, Rank.new(3, [1])[1]
    end

    it "throws an IndexError if the given position is not valid" do
      assert_raises(IndexError) { Rank.new(3, [])[4] }
      assert_raises(IndexError) { Rank.new(3, [])[0] }
    end
  end

  describe "#[]=" do
    it "allows assigning values with 1 base index" do
      rank = Rank.new(3, [])
      rank[1] = "value"
      assert_equal "value", rank[1]
    end

    it "throws an IndexError if the given position is not valid" do
      assert_raises(IndexError) { Rank.new(3, [])[4] = "value" }
      assert_raises(IndexError) { Rank.new(3, [])[0] = "value" }
    end
  end

  describe "#adjust_empty_spaces" do
    it "increments empty spaces when assigning a nil value to a filled " \
      "position" do
      rank = Rank.new(3, [1, 2, 3])
      assert_equal 1, rank.adjust_empty_spaces(0, nil)
    end

    it "decrements empty spaces when assigning a new value to an empty space" do
      rank = Rank.new(3, [1, 3])
      assert_equal 0, rank.adjust_empty_spaces(2, 2)
    end
  end

  describe "#each_with_index" do
    it "passes through to the @rank's method" do
      rank = Rank.new(3, [1, 2, 3])
      expect(rank.rank).to receive(:each_with_index)
      rank.each_with_index { |_, index| index }
    end
  end

  describe "#reverse!" do
    it "reverses the rank in place" do
      rank = Rank.new(3, [1, 2, 3])
      assert_equal [3, 2, 1], rank.reverse!
    end
  end

  describe "#size" do
    it "returns the size of the rank" do
      rank = Rank.new(3)
      assert_equal 3, rank.size
    end
  end

  describe "#fill_blank_spaces" do
    it "adds nil values for empty spaces" do
      rank = Rank.new(3, [])
      assert_equal [nil, nil, nil], rank.rank
      rank = Rank.new(3, [1])
      assert_equal [1, nil, nil], rank.rank
    end
  end

  describe "#fill!" do
    it "fills the empty spaces with the given value" do
      rank = Rank.new(3, [])
      rank.fill!(1)
      assert_equal [1, 1, 1], rank.rank
    end

    it "fills the empty spaces up to the given number" do
      rank = Rank.new(3, [])
      rank.fill!("value", 2)
      assert_equal ["value", "value", nil], rank.rank
    end
  end

  describe "#value_count" do
    it "returns the number of matches in the row for the given value" do
      rank = Rank.new(3, ["value", nil, "value"])
      assert_equal 2, rank.value_count("value")
    end
  end
end

