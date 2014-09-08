require File.expand_path(File.dirname(__FILE__) + "/../unit")
require "factories/unit_factory"

describe Unit do
  subject { UnitFactory.new }

  describe "#check_break_test" do
    let(:model) { ModelFactory.new.parts([PartFactory.new.leadership(7).build])
                    .build }
    let(:unit) { subject.model(model).size(20).build }

    it "returns true if the test is passed" do
      roll = 6
      modifier = -1
      expect(unit.check_break_test(roll, modifier)).to be_true
    end

    it "returns true if the roll is snake eyes" do
      roll = 2
      modifier = -100
      expect(unit.check_break_test(roll, modifier)).to be_true
    end

    it "returns false if the unit fails the test" do
      roll = 8
      modifier = -1
      expect(unit.check_break_test(roll, modifier)).to be_false
    end
  end

  describe "#convert_coordinate" do
    let(:unit) { subject.offset(40).width(10).build }

    it "converts the coordinate of the opposing unit to the given unit" do
      expect(unit.convert_coordinate(100)).to eq(140)
      expect(unit.convert_coordinate(20)).to eq(220)
      expect(unit.convert_coordinate(200)).to eq(40)
    end
  end

  describe "#dead?" do
    it "is true when there are no models left" do
      unit = subject.size(0).build
      expect(unit.dead?).to be_true
    end

    it "is false when there models left" do
      unit = subject.build
      expect(unit.dead?).to be_false
    end
  end

  describe "#farthest_back_special_model_occupied_space" do
    let(:special_models) do
      { [1, 5] => ModelFactory.new.mm_width(40).mm_length(40).build }
    end

    it "returns the rank of the farthest back special model space" do
      unit = subject.size(20).special_models(special_models).build
      expect(unit.farthest_back_special_model_occupied_space).to eq(2)
    end

    it "returns the rank even when there aren't regular models in the rank" do
      unit = subject.size(1).special_models(special_models).build
      expect(unit.farthest_back_special_model_occupied_space).to eq(2)
    end
  end

  describe "#is_horde?" do
    it "returns true if the width is wide enough" do
      unit = subject.width(10).build
      expect(unit.is_horde?).to be_true
    end

    it "returns true if special models fill in the missing regular models" do
      special_models = { [1, 5] => ModelFactory.new.mm_width(40).build }
      unit = subject.width(10).size(8).special_models(special_models).build
      expect(unit.is_horde?).to be_true
    end

    it "returns false if not wide enough" do
      unit = subject.width(5).build
      expect(unit.is_horde?).to be_false
    end

    it "returns false even if wide enough if there aren't enough models" do
      unit = subject.width(10).size(9).build
      expect(unit.is_horde?).to be_false
    end
  end

  describe "#is_steadfast?" do
    let(:unit) { subject.size(20).build }

    it "returns true when the unit has more ranks than the defender" do
      defender_ranks = 3
      expect(unit.is_steadfast?(defender_ranks)).to be_true
    end

    it "returns false when the unit doesn't" do
      defender_ranks = 4
      expect(unit.is_steadfast?(defender_ranks)).to be_false
    end
  end

  describe "#item_manipulation" do
    let(:unit) { subject.build }

    it "defaults to the starting value" do
      starting_value = 50
      expect(unit.item_manipulation(nil, starting_value)).to eq(starting_value)
    end

    it "calls the method for each item" do
      starting_value = 0
      args = [1, 2, 3]
      item = Equipment.new
      item.should_receive(:test_method).with(*args).and_return(starting_value)
      unit = subject.equipment([item]).build
      expect(unit.item_manipulation(:test_method, starting_value,
                                    *args)).to eq(starting_value)
    end
  end

  describe "#left_flank_location" do
    it "is defined as zero" do
      unit = subject.build
      expect(unit.left_flank_location).to eq(0)
    end
  end

  describe "#mm_width" do
    it "returns the width of the unit in millimeters" do
      unit = subject.width(5).build
      expect(unit.mm_width).to eq(100)
    end
  end

  describe "#model_count" do
    it "returns the number of models in the unit including special models" do
      special_models = { [1, 5] => ModelFactory.new.mm_width(40).build }
      unit = subject.size(20).special_models(special_models).build
      expect(unit.model_count).to eq(21)
    end
  end

  describe "#models_in_mm_range" do
    let(:special_models) do
      { [1, 5] => ModelFactory.new.name("champion").mm_width(40).mm_length(40)
                    .build }
    end
    let(:unit) do
      subject.special_models(special_models).build
    end

    it "finds the models that fall within the given range" do
      expect(unit.models_in_mm_range(0, 79)).to eq([unit.model])
    end

    it "finds both models and special models" do
      expect(unit.models_in_mm_range(0, 100)).to eq([special_models[[1, 5]],
                                                     unit.model])
    end

    it "finds the model on right if the second value is between two models" do
      expect(unit.models_in_mm_range(80, 80)).to eq([special_models[[1, 5]],
                                                     unit.model])
    end

    it "finds the model on left if the first value is between two models" do
      expect(unit.models_in_mm_range(80, 80)).to eq([special_models[[1, 5]],
                                                     unit.model])
    end

    it "doesn't return duplicate models" do
      expect(unit.models_in_mm_range(0, 200)).to eq([special_models[[1, 5]],
                                                     unit.model])
    end
  end

  describe "#number_of_ranks" do
    it "returns the number of ranks whether full or not" do
      special_models = { [1, 5] => ModelFactory.new.mm_width(40).mm_length(100)
                                     .build }
      unit = subject.size(10).special_models(special_models).build
      expect(unit.number_of_ranks).to eq(5)
    end

    it "returns the number of ranks when there are many many models" do
      unit = subject.width(10).size(100).build
      expect(unit.number_of_ranks).to eq(10)
    end
  end

  describe "#positions_occupied" do
    it "returns the number of unit positions that are occupied" do
      special_models = { [1, 5] => ModelFactory.new.mm_width(40).mm_length(40)
                                     .build }
      unit = subject.size(20).special_models(special_models).build
      expect(unit.positions_occupied).to eq(24)
    end
  end

  describe "#rank_bonus" do
    it "returns the rank bonus of the unit" do
      unit = subject.size(20).width(5).build
      expect(unit.rank_bonus).to eq(3)
    end

    it "returns the rank bonus when there are special models" do
      special_models = { [1, 2] => ModelFactory.new.mm_width(40).mm_length(40)
                                     .build }
      unit = subject.size(11).width(5).special_models(special_models).build
      expect(unit.rank_bonus).to eq(2)
    end
  end

  describe "#right_flank_location" do
    it "is the left flank plus the width of unit in millimeters" do
      unit = subject.width(10).build
      expect(unit.right_flank_location).to eq(200)
    end
  end

  describe "#special_model_occupied_spaces_in_rank" do
    let(:special_models) do
      { [1, 2] => ModelFactory.new.mm_width(40).mm_length(40).build }
    end
    let(:unit) { subject.size(40).special_models(special_models).build }

    it "returns 2 spaces for the first rank" do
      expect(unit.special_model_occupied_spaces_in_rank(1)).to eq(2)
    end

    it "returns 2 spaces for the second rank" do
      expect(unit.special_model_occupied_spaces_in_rank(2)).to eq(2)
    end

    it "returns 0 spaces for the third rank" do
      expect(unit.special_model_occupied_spaces_in_rank(3)).to eq(0)
    end

    it "returns 0 spaces for the fourth rank" do
      expect(unit.special_model_occupied_spaces_in_rank(4)).to eq(0)
    end
  end

  describe "#stats" do
    it "delegates to the item caller method" do
      round_number = 1
      unit = subject.build
      unit.should_receive(:item_manipulation).with(:stats, unit.model,
                                                   round_number)
      unit.stats(round_number)
    end
  end

 #describe "#model_in_position" do
  #  let(:model) { ModelFactory.new.mm_width(20).mm_length(20).build }
 #  let(:special_models) do
  #    { [1, 5] => ModelFactory.new.mm_width(20).mm_length(20).build 20) }
 #  end
 #  let(:unit) do
 #    UnitFactory.new.model(model).special_models(special_models).build
 #  end

 #  it "returns a special model when the model is in the position" do
 #    expect(unit.model_in_position(1, 5)).to eq(special_models[[1, 5]])
 #  end

 #  it "returns the unit model otherwise" do
 #    expect(unit.model_in_position(2, 5)).to eq(model)
 #  end
 #end
end

