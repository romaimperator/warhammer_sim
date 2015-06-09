require "spec_helper"
require_relative "../alignment_strategy"
require_relative "../rank"

describe CenterAlignStrategy do
  describe ".fill_locations" do
    let(:rank_list) { [Rank.new(5), Rank.new(5)] }

    it "yields successive locations" do
      locations_expected = [
        [1, 3],
        [1, 2],
        [1, 4],
        [1, 1],
        [1, 5],
        [2, 3],
        [2, 2],
        [2, 4],
        [2, 1],
        [2, 5],
      ]
      assert_equal locations_expected,
                   CenterAlignStrategy.fill_locations(rank_list, nil).to_a
    end

    it "skips over filled locations" do
      locations_expected = [
        [1, 2],
        [1, 4],
        [1, 1],
        [1, 5],
        [2, 3],
        [2, 2],
        [2, 4],
        [2, 1],
        [2, 5],
      ]
      rank_list[0][3] = "champ"
      assert_equal locations_expected,
                   CenterAlignStrategy.fill_locations(rank_list, nil).to_a
    end

    it "returns an enumerator if no block is given" do
      assert_kind_of Enumerator, CenterAlignStrategy.fill_locations(nil)
    end
  end

  describe ".remove_locations" do
    let(:rank_list) { [Rank.new(5, ["unit"] * 5), Rank.new(5, ["unit"] * 5)] }

    it "yields successive locations" do
      locations_expected = [
        [2, 5],
        [2, 1],
        [2, 4],
        [2, 2],
        [2, 3],
        [1, 5],
        [1, 1],
        [1, 4],
        [1, 2],
        [1, 3],
      ]
      assert_equal locations_expected,
                   CenterAlignStrategy.remove_locations(rank_list, "unit").to_a
    end

    it "skips over filled locations" do
      locations_expected = [
        [2, 5],
        [2, 1],
        [2, 4],
        [2, 2],
        [1, 5],
        [1, 1],
        [1, 4],
        [1, 2],
      ]
      rank_list[0][3] = "champ"
      rank_list[1][3] = "champ"
      assert_equal locations_expected,
                   CenterAlignStrategy.remove_locations(rank_list, "unit").to_a
    end

    it "returns an enumerator if no block is given" do
      assert_kind_of Enumerator, CenterAlignStrategy.remove_locations(nil, nil)
    end
  end
end

describe LeftAlignStrategy do
  describe ".fill_locations" do
    let(:rank_list) { [Rank.new(5), Rank.new(5)] }

    it "yields successive locations" do
      locations_expected = [
        [1, 1],
        [1, 2],
        [1, 3],
        [1, 4],
        [1, 5],
        [2, 1],
        [2, 2],
        [2, 3],
        [2, 4],
        [2, 5],
      ]
      assert_equal locations_expected,
                   LeftAlignStrategy.fill_locations(rank_list, nil).to_a
    end

    it "skips over filled locations" do
      locations_expected = [
        [1, 1],
        [1, 2],
        [1, 4],
        [1, 5],
        [2, 1],
        [2, 2],
        [2, 3],
        [2, 4],
        [2, 5],
      ]
      rank_list[0][3] = "champ"
      assert_equal locations_expected,
                   LeftAlignStrategy.fill_locations(rank_list, nil).to_a
    end

    it "returns an enumerator if no block is given" do
      assert_kind_of Enumerator, LeftAlignStrategy.fill_locations(nil)
    end
  end

  describe ".remove_locations" do
    let(:rank_list) { [Rank.new(5, ["unit"] * 5), Rank.new(5, ["unit"] * 5)] }

    it "yields successive locations" do
      locations_expected = [
        [2, 5],
        [2, 4],
        [2, 3],
        [2, 2],
        [2, 1],
        [1, 5],
        [1, 4],
        [1, 3],
        [1, 2],
        [1, 1],
      ]
      assert_equal locations_expected,
                   LeftAlignStrategy.remove_locations(rank_list, "unit").to_a
    end

    it "skips over filled locations" do
      locations_expected = [
        [2, 5],
        [2, 4],
        [2, 2],
        [2, 1],
        [1, 5],
        [1, 4],
        [1, 2],
        [1, 1],
      ]
      rank_list[0][3] = "champ"
      rank_list[1][3] = "champ"
      assert_equal locations_expected,
                   LeftAlignStrategy.remove_locations(rank_list, "unit").to_a
    end

    it "returns an enumerator if no block is given" do
      assert_kind_of Enumerator, LeftAlignStrategy.remove_locations(nil, nil)
    end
  end
end

describe RightAlignStrategy do
  describe ".fill_locations" do
    let(:rank_list) { [Rank.new(5), Rank.new(5)] }

    it "yields successive locations" do
      locations_expected = [
        [1, 5],
        [1, 4],
        [1, 3],
        [1, 2],
        [1, 1],
        [2, 5],
        [2, 4],
        [2, 3],
        [2, 2],
        [2, 1],
      ]
      assert_equal locations_expected,
                   RightAlignStrategy.fill_locations(rank_list, nil).to_a
    end

    it "skips over filled locations" do
      locations_expected = [
        [1, 5],
        [1, 4],
        [1, 2],
        [1, 1],
        [2, 5],
        [2, 4],
        [2, 2],
        [2, 1],
      ]
      rank_list[0][3] = "champ"
      rank_list[1][3] = "champ"
      assert_equal locations_expected,
                   RightAlignStrategy.fill_locations(rank_list, nil).to_a
    end

    it "returns an enumerator if no block is given" do
      assert_kind_of Enumerator, RightAlignStrategy.fill_locations(nil)
    end
  end

  describe ".remove_locations" do
    let(:rank_list) { [Rank.new(5, ["unit"] * 5), Rank.new(5, ["unit"] * 5)] }

    it "yields successive locations" do
      locations_expected = [
        [2, 1],
        [2, 2],
        [2, 3],
        [2, 4],
        [2, 5],
        [1, 1],
        [1, 2],
        [1, 3],
        [1, 4],
        [1, 5],
      ]
      assert_equal locations_expected,
                   RightAlignStrategy.remove_locations(rank_list, "unit").to_a
    end

    it "skips over filled locations" do
      locations_expected = [
        [2, 1],
        [2, 2],
        [2, 3],
        [2, 4],
        [2, 5],
        [1, 1],
        [1, 2],
        [1, 4],
        [1, 5],
      ]
      rank_list[0][3] = "champ"
      assert_equal locations_expected,
                   RightAlignStrategy.remove_locations(rank_list, "unit").to_a
    end

    it "returns an enumerator if no block is given" do
      assert_kind_of Enumerator, RightAlignStrategy.remove_locations(nil, nil)
    end
  end
end

