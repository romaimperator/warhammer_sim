require "spec_helper"
require "rank_and_file_unit"
require "part"
require "model"
require "rank_and_file_model"
require "round_result"
require "round"
require "equipment/halberd"

describe Round do
  describe "#simulate" do
    let(:attacker) do
      RankAndFileUnit.new_with_positions(10, RankAndFileModel.new("halberd", [
        Part.new("man", 3, 3, 3, 1, 3, 1, 7, 6, 7, []),
      ], 20, 20, [Halberd.new]), 40, {}, -40)
    end
    let(:defender) do
      champ = Model.new("champ", [
        Part.new("champ", 4, 3, 3, 1, 6, 3, 7, 7, 7, [])
      ], 20, 20, [])
      RankAndFileUnit.new_with_positions(7, RankAndFileModel.new("witch elf", [
        Part.new("elf", 4, 3, 3, 1, 5, 2, 7, 7, 7, []),
      ], 20, 20, []), 21, {[1, 3] => champ}, 20)
    end
    subject { Round.new(1, attacker, defender) }

    it "returns a RoundResult option" do
      assert_instance_of RoundResult, subject.simulate
    end
  end
end

