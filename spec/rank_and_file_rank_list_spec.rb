require "spec_helper"
require "rank_and_file_rank_list"
require "alignment_strategy"

describe RankAndFileRankList do
  it "delegates methods to the given RankList" do
    rank_list = instance_spy("RankList", at: nil)
    RankAndFileRankList.new(rank_list, nil).at(1, 2)
    expect(rank_list).to have_received(:at).with(1, 2)
  end

  describe "#each_model" do
    it "returns an enumerator if no block is given" do
      rank_list = RankList.new(5, 1)
      assert_instance_of Enumerator, RankAndFileRankList.new(rank_list, "value").each_model
    end

    it "returns each model with rank, file, and model" do
      rank_list = RankList.new(5, 1)
      rank_list.fill!("value", 5)
      results = []
      RankAndFileRankList.new(rank_list, "value").each_model do |rank, file, unit|
        results << [rank, file, unit]
      end
      assert_equal [[1, 1, "value"],
                    [1, 2, "value"],
                    [1, 3, "value"],
                    [1, 4, "value"],
                    [1, 5, "value"]], results
    end

    it "returns any non-rank and file model only once at the front-left most position" do
      rank_list = RankList.new(5, 1, AlignmentStrategy::Left)
      rank_list.fill!("value", 2)
      rank_list.fill!("champ", 2)
      rank_list.fill!("value", 1)
      results = []
      RankAndFileRankList.new(rank_list, "value").each_model do |rank, file, unit|
        results << [rank, file, unit]
      end
      assert_equal [[1, 1, "value"],
                    [1, 2, "value"],
                    [1, 3, "champ"],
                    [1, 5, "value"]], results
    end
  end
end
