require 'spec_helper'
require_relative '../rank_list'
require_relative '../alignment_strategy'

describe RankList do
  describe "#at" do
    it "retrieves the value at the given rank and file" do
      list = RankList.new(5, 1)
      list.set(3, 1, "value")
      assert_equal "value", list.at(3, 1)
    end
  end

  describe "#set" do
    it "stores the value at the given rank and file" do
      list = RankList.new(5, 1)
      list.set(3, 1, "value")
      assert_equal "value", list.at(3, 1)
    end
  end

  describe "#fill!" do
    it "fills the empty spaces with the given value" do
      list = RankList.new(5, 1)
      list.fill!("value")
      assert_equal Rank.new(5, ["value"] * 5), list.the_grid[0]
    end

    it "fills only up to the given number of empty spaces" do
      list = RankList.new(5, 2, LeftAlignStrategy)
      list.fill!("value", 7)
      assert_equal [Rank.new(5, ["value"] * 5), Rank.new(5, ["value"] * 2)], list.the_grid
    end

    it "adds extra ranks if there weren't enough spaces in existing ranks" do
      list = RankList.new(5, 1, LeftAlignStrategy)
      list.fill!("value", 6)
      assert_equal [Rank.new(5, ["value"] * 5), Rank.new(5, ["value"])], list.the_grid
    end
  end

  describe "#count_in_rank" do
    it "counts the number of matches in the given row for the given value" do
      list = RankList.new(5, 1)
      list.fill!("value", 3)
      assert_equal 3, list.count_in_rank(1, "value")
    end
  end
end

