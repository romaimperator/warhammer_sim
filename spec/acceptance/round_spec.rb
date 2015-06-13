require "spec_helper"
require "rank_and_file_unit"
require "part"
require "model"
require "rank_and_file_model"
require "round_result"
require "round"
require "equipment"
require "stats"
require "champion"

describe Round do
  describe "#simulate" do
    let(:attacker) do
      halberd = RankAndFileModel.new("halberd", 20, 20, [Equipment::Halberd.new],
                                     Stats.new(3, 3, 3, 1, 3, 1, 7, 6, 7))
      RankAndFileUnit.new_with_positions(10, halberd, 40, {}, -40)
    end
    let(:defender) do
      champ = Champion.new("champ", 20, 20, [], Stats.new(4, 3, 3, 1, 6, 3, 7, 7, 7))
      witch_elf = RankAndFileModel.new("witch elf", 20, 20, [],
                                       Stats.new(4, 3, 3, 1, 5, 2, 7, 7, 7))
      RankAndFileUnit.new_with_positions(7, witch_elf, 0, {[1, 3] => champ}, 20)
    end
    subject { Round.new(1, attacker, defender) }

    it "returns a RoundResult option" do
      assert_instance_of RoundResult, subject.simulate
      p subject.defender.model_count
    end
  end
end

