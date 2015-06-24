require "spec_helper"
require_relative "../alignment_strategy"
require_relative "../rank"

module AlignmentStrategy
  describe Center do
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
                     Center.fill_locations(rank_list, nil).to_a
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
                     Center.fill_locations(rank_list, nil).to_a
      end

      it "returns an enumerator if no block is given" do
        assert_kind_of Enumerator, Center.fill_locations(nil)
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
                     Center.remove_locations(rank_list, "unit").to_a
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
                     Center.remove_locations(rank_list, "unit").to_a
      end

      it "returns an enumerator if no block is given" do
        assert_kind_of Enumerator, Center.remove_locations(nil, nil)
      end
    end
  end

  describe Left do
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
                     Left.fill_locations(rank_list, nil).to_a
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
                     Left.fill_locations(rank_list, nil).to_a
      end

      it "returns an enumerator if no block is given" do
        assert_kind_of Enumerator, Left.fill_locations(nil)
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
                     Left.remove_locations(rank_list, "unit").to_a
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
                     Left.remove_locations(rank_list, "unit").to_a
      end

      it "returns an enumerator if no block is given" do
        assert_kind_of Enumerator, Left.remove_locations(nil, nil)
      end
    end
  end

  describe Right do
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
                     Right.fill_locations(rank_list, nil).to_a
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
                     Right.fill_locations(rank_list, nil).to_a
      end

      it "returns an enumerator if no block is given" do
        assert_kind_of Enumerator, Right.fill_locations(nil)
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
                     Right.remove_locations(rank_list, "unit").to_a
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
                     Right.remove_locations(rank_list, "unit").to_a
      end

      it "returns an enumerator if no block is given" do
        assert_kind_of Enumerator, Right.remove_locations(nil, nil)
      end
    end
  end
end
