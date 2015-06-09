require "spec_helper"
require_relative "../target_strategy"
require_relative "factories/rank_and_file_unit_factory"

describe TargetStrategy::RankAndFileFirst do
  let(:rank_and_file) { ModelFactory.new.build }
  let(:defender) { RankAndFileUnitFactory.new }
  subject { TargetStrategy::RankAndFileFirst.new(nil, defender) }

  it "returns the rank and file unit when it is a target" do
    targets = [rank_and_file, ModelFactory.new.name("champ").build]
    expect(defender).to receive(:rank_and_file).exactly(2).times { rank_and_file }
    assert_equal rank_and_file, subject.pick(targets)
  end

  it "returns a random target when the rank and file isn't a target" do
    targets = [ModelFactory.new.name("champ").build, ModelFactory.new.name("char").build]
    expect(defender).to receive(:rank_and_file) { rank_and_file }
    expect(TargetStrategy::RandomTarget).to receive(:new).and_call_original
    subject.pick(targets)
  end
end

