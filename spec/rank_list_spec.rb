require "spec_helper"
require "rank_list"
require "alignment_strategy"

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

    it "adds as many new ranks as needed if the value for rank is larger than the current size" do
      list = RankList.new(5, 1)
      list.set(3, 4, "value")
      assert_equal "value", list.at(3, 4)
      assert_equal 4, list.the_grid.size
    end
  end

  describe "#fill!" do
    it "fills the empty spaces with the given value" do
      list = RankList.new(5, 1)
      list.fill!("value")
      assert_equal Rank.new(5, ["value"] * 5), list.the_grid[0]
    end

    it "fills only up to the given number of empty spaces" do
      list = RankList.new(5, 2, AlignmentStrategy::Left)
      list.fill!("value", 7)
      assert_equal [Rank.new(5, ["value"] * 5), Rank.new(5, ["value"] * 2)],
                   list.the_grid
    end

    it "adds extra ranks if there weren't enough spaces in existing ranks" do
      list = RankList.new(5, 1, AlignmentStrategy::Left)
      list.fill!("value", 6)
      assert_equal [Rank.new(5, ["value"] * 5), Rank.new(5, ["value"])],
                   list.the_grid
      assert_equal 2, list.the_grid.size
    end

    it "adds enough ranks to allow full filling" do
      list = RankList.new(5, 1, AlignmentStrategy::Left)
      list.fill!("value", 11)
      assert_equal 3, list.the_grid.size
    end

    it "uses the alignment strategy" do
      allow(AlignmentStrategy::Left).to receive(:fill_locations).and_call_original
      list = RankList.new(5, 1, AlignmentStrategy::Left)
      list.fill!("value", 1)
      expect(AlignmentStrategy::Left).to have_received(:fill_locations).with(list.the_grid).at_least(:once)
    end
  end

  describe "#unfill!" do
    subject do
      list = RankList.new(5, 2, AlignmentStrategy::Left)
      list.fill!("value", 10)
      list
    end

    it "removes the given number of the given value" do
      subject.unfill!("value", 4)
      assert_equal [Rank.new(5, ["value"] * 5), Rank.new(5, ["value"])],
                   subject.the_grid
    end

    it "removes all of them if the given number is more than the number in " \
      "the unit" do
      subject.unfill!("value", 11)
      assert_equal [], subject.the_grid
    end

    it "removes any empty ranks left over" do
      subject.unfill!("value", 5)
      assert_equal [Rank.new(5, ["value"] * 5)], subject.the_grid
      assert_equal 1, subject.the_grid.size
    end

    it "uses the alignment strategy" do
      allow(AlignmentStrategy::Left).to receive(:remove_locations).and_call_original
      subject.unfill!("value", 1)
      expect(AlignmentStrategy::Left).to have_received(:remove_locations).with(subject.the_grid, "value")
    end
  end

  describe "#count_in_rank" do
    it "counts the number of matches in the given row for the given value" do
      list = RankList.new(5, 1)
      list.fill!("value", 3)
      assert_equal 3, list.count_in_rank(1, "value")
    end
  end

  describe "#each_position" do
    let(:list) { RankList.new(5, 1, AlignmentStrategy::Left) }

    it "returns an enumerator if no block is given" do
      assert_instance_of Enumerator, list.each_position
    end

    it "yields every position with rank, file, and thing at that position" do
      list.fill!("value", 5)
      results = []
      list.each_position do |rank, file, unit|
        results << [rank, file, unit]
      end
      assert_equal [[1, 1, "value"],
                    [1, 2, "value"],
                    [1, 3, "value"],
                    [1, 4, "value"],
                    [1, 5, "value"]], results
    end

    it "skips over empty spaces" do
      list.fill!("value", 2)
      results = []
      list.each_position do |rank, file, unit|
        results << [rank, file, unit]
      end
      assert_equal [[1, 1, "value"],
                    [1, 2, "value"]], results
    end
  end

  describe "#find_each" do
    let(:list) { RankList.new(5, 1, AlignmentStrategy::Left) }

    it "returns an enumerator if no block is given" do
      assert_instance_of Enumerator, list.find_each(nil)
    end

    it "yields every position with rank, file, and thing where thing matches the given value" do
      list.fill!("value", 3)
      list.fill!("other", 3)
      list.fill!("value", 1)
      results = []
      list.find_each("value") do |rank, file, unit|
        results << [rank, file, unit]
      end
      assert_equal [[1, 1, "value"],
                    [1, 2, "value"],
                    [1, 3, "value"],
                    [2, 2, "value"]], results
    end

    it "skips over empty spaces" do
      list.fill!("value", 3)
      results = []
      list.find_each("value") do |rank, file, unit|
        results << [rank, file, unit]
      end
      assert_equal [[1, 1, "value"],
                    [1, 2, "value"],
                    [1, 3, "value"]], results
    end
  end
end

