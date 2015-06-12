require "benchmark/ips"

require "spec_helper"
require "factories/rank_and_file_unit_factory"
require "attack_matchup"

describe RankAndFileUnit do
  describe "#dead?" do
    it "is true when all contained units are dead" do
      unit = RankAndFileUnitFactory.new.container_unit_count(0).other_units(
        [1, 3] => double("model", dead?: true, 'unit=': nil)
      ).build
      assert unit.dead?
    end

    it "is false if there are models left in the unit" do
      unit = RankAndFileUnitFactory.new.container_unit_count(5).build
      refute unit.dead?
    end

    it "is false if any contained units are not dead" do
      unit = RankAndFileUnitFactory.new.container_unit_count(0).other_units(
        [1, 3] => double("model", dead?: false, 'unit=': nil)
      ).build
      refute unit.dead?
    end
  end

  describe "#model_count" do
    let(:size) { 11 }
    subject { RankAndFileUnitFactory.new.container_unit_count(size).build_positions }

    it "is the number of models in the unit" do
      assert_equal size, subject.model_count
    end

    describe "when there are other units" do
      subject do
        RankAndFileUnitFactory.new.files(size).container_unit_count(size)
          .other_units(
            [1, 3] => ModelFactory.new.mm_length(20).mm_width(40).build
          ).build
      end

      it "also counts the spaces taken up by the other units" do
        assert_equal size + 1, subject.model_count
      end
    end
  end

  describe "#mm_width" do
    it "is the width of the whole unit" do
      unit = RankAndFileUnitFactory.new.files(5).container_unit_count(5).build
      assert_equal 100, unit.mm_width
    end
  end

  describe "#mm_length" do
    it "is the length of the whole unit" do
      unit = RankAndFileUnitFactory.new.files(5).container_unit_count(15).build
      assert_equal 60, unit.mm_length
    end
  end

  describe "#number_of_ranks" do
    it "is the number of ranks in the unit" do
      unit = RankAndFileUnitFactory.new.files(5).container_unit_count(20).build
      assert_equal 4, unit.length
    end

    it "works with partially filled ranks" do
      unit = RankAndFileUnitFactory.new.files(5).container_unit_count(16).build
      assert_equal 4, unit.length
    end
  end

  describe "#occupied_spaces" do
    let(:size) { 11 }
    subject { RankAndFileUnitFactory.new.container_unit_count(11).build_positions }

    it "is the number of models in the unit" do
      assert_equal size, subject.occupied_spaces
    end

    describe "when there are other units" do
      subject do
        RankAndFileUnitFactory.new.files(size).container_unit_count(size)
          .other_units(
            [1, 3] => ModelFactory.new.mm_length(20).mm_width(40).build
          ).build
      end

      it "also counts the spaces taken up by the other units" do
        assert_equal size + 2, subject.occupied_spaces
      end
    end
  end

  describe "#left" do
    # TODO: Implement this test
  end

  describe "#right" do
    # TODO: Implement this test
  end

  describe "#targets_in_intervals" do
    let(:champ) { ModelFactory.new.name("champ").mm_width(20).build }

    it "returns a list of targets with number of targeters" do
      other_units = {
        [1, 4] => champ
      }
      unit = RankAndFileUnitFactory.new.files(5).other_units(other_units)
        .build_positions
      assert_equal ({[unit.container_unit] => 2, [champ, unit.container_unit] => 3}),
                   unit.targets_in_intervals([[0, 20], [20, 40], [40, 60],
                                             [60, 80], [80, 100]])
    end

    it "works if the champ is on one end" do
      other_units = {
        [1, 5] => champ
      }
      unit = RankAndFileUnitFactory.new.files(5).other_units(other_units)
        .build_positions
      assert_equal ({[champ, unit.container_unit] => 2, [unit.container_unit] => 3}),
                   unit.targets_in_intervals([[0, 20], [20, 40], [40, 60],
                                             [60, 80], [80, 100]])
    end
  end

  describe "#take_wounds" do
    let(:unit) do
      RankAndFileUnitFactory.new.container_unit_count(10).build_positions
    end

    it "lowers the size of the unit" do
      unit.take_wounds(7)
      assert_equal 3, unit.model_count
    end

    it "sets the size to 0 if told to take more wounds than the size" do
      unit.take_wounds(20)
      assert_equal 0, unit.model_count
    end

    it "removes models from the position set" do
      unit.take_wounds(7)
      comparison_unit =
        RankAndFileUnitFactory.new.container_unit_count(3).build_positions
      assert_equal comparison_unit.positions, unit.positions
    end
  end

  describe "#initiative_steps" do
    it "returns a set of all initiative values in the unit" do
      unit = RankAndFileUnitFactory.new.build
      assert_equal [3], unit.initiative_steps(1)
    end

    it "includes any units inside of the rank and file unit" do
      champion =
        ModelFactory.new.parts([PartFactory.new.initiative(6).build]).build
      unit = RankAndFileUnitFactory.new.other_units([1, 3] => champion).build
      assert_equal [3, 6], unit.initiative_steps(1)
    end
  end

  describe "#matchups_for_initiative" do
    it "returns a list of matchup objects for units with the given initiative" do
      unit = RankAndFileUnitFactory.new.build_positions
      defender = RankAndFileUnitFactory.new.build_positions
      initiative = 3
      round_number = 1
      assert_equal [AttackMatchup.new(round_number, unit.rank_and_file, 20, defender.rank_and_file)],
                   unit.matchups_for_initiative(initiative, round_number, defender)
    end

    it "includes other units if they match the initiative" do
      champ = ModelFactory.new.name("champ").parts([PartFactory.new.initiative(5).attacks(2).build]).build
      unit = RankAndFileUnitFactory.new.other_units(
        [1, 3] => champ
      ).build_positions
      defender = RankAndFileUnitFactory.new.build_positions
      initiative = 5
      round_number = 1
      assert_equal [AttackMatchup.new(round_number, champ, 2, defender.rank_and_file)],
                   unit.matchups_for_initiative(initiative, round_number, defender)
    end

    it "does not double count other units that take up more than one space" do
      champ = ModelFactory.new.name("champ").mm_width(40).parts([PartFactory.new.initiative(5).attacks(2).build]).build
      unit = RankAndFileUnitFactory.new.other_units(
        [1, 3] => champ
      ).build_positions
      defender = RankAndFileUnitFactory.new.build_positions
      initiative = 5
      round_number = 1
      assert_equal [AttackMatchup.new(round_number, champ, 2, defender.rank_and_file)],
                   unit.matchups_for_initiative(initiative, round_number, defender)
    end
  end
end

