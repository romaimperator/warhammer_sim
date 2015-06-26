require "spec_helper"
require "target_strategy"
require "factories/rank_and_file_unit_factory"
require "factories/model_factory"

module TargetStrategy
  describe RankAndFileFirst do
    let(:rank_and_file) { ModelFactory.new.build }
    let(:defender) { RankAndFileUnitFactory() }
    subject { RankAndFileFirst.new(nil, defender) }

    it "returns the rank and file unit when it is a target" do
      targets = [rank_and_file, ModelFactory.new.name("champ").build]
      expect(defender).to receive(:rank_and_file).exactly(2).times { rank_and_file }
      assert_equal rank_and_file, subject.pick(targets)
    end

    it "returns a random target when the rank and file isn't a target" do
      targets = [ModelFactory.new.name("champ").build, ModelFactory.new.name("char").build]
      expect(defender).to receive(:rank_and_file) { rank_and_file }
      expect(RandomTarget).to receive(:new).and_call_original
      subject.pick(targets)
    end
  end

  describe NonRankAndFileFirst do
    let(:rank_and_file) { ModelFactory.new.build }
    let(:defender) { RankAndFileUnitFactory() }
    subject { NonRankAndFileFirst.new(nil, defender) }

    it "returns the non-rank and file unit when there is one" do
      targets = [rank_and_file, champ = ModelFactory.new.name("champ").build]
      allow(defender).to receive(:rank_and_file) { rank_and_file }
      assert_equal champ, subject.pick(targets)
    end

    it "returns a random non-rank and file unit when there is more than one" do
      targets = [ModelFactory.new.name("champ").build, ModelFactory.new.name("champ2").build]
      allow(defender).to receive(:rank_and_file) { nil }
      allow(RandomTarget).to receive(:new).and_return(rand = double(pick: targets[0]))
      subject.pick(targets)
      expect(rand).to have_received(:pick).with(targets)
    end

    it "returns the rank and file unit when it is the only option" do
      targets = [rank_and_file]
      allow(defender).to receive(:rank_and_file) { rank_and_file }
      assert_equal rank_and_file, subject.pick(targets)
    end
  end
end

