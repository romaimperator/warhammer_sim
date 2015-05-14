require 'spec_helper'
require_relative 'factories/rank_and_file_unit_factory'

describe RankAndFileUnit do
  describe "#dead?" do
    it "is true when all contained units are dead" do
      unit = RankAndFileUnitFactory.new.container_unit_count(0).other_units([1, 3] => double('model', :dead? => true)).build
      assert unit.dead?
    end

    it "is false if there are models left in the unit" do
      unit = RankAndFileUnitFactory.new.container_unit_count(5).build
      refute unit.dead?
    end

    it "is false if any contained units are not dead" do
      unit = RankAndFileUnitFactory.new.container_unit_count(0).other_units([1, 3] => double('model', :dead? => false)).build
      refute unit.dead?
    end
  end

  describe "#model_count" do
    let(:size) { 11 }
    subject { RankAndFileUnit.new(size, nil, size, {}) }

    it "is the number of models in the unit" do
      assert_equal size, subject.model_count
    end

    describe "when there are other units" do
      subject { RankAndFileUnitFactory.new.files(size).container_unit_count(size).other_units([1, 3] => ModelFactory.new.mm_length(20).mm_width(40).build).build }

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
    subject { RankAndFileUnit.new(size, nil, size, {}) }

    it "is the number of models in the unit" do
      assert_equal size, subject.occupied_spaces
    end

    describe "when there are other units" do
      subject { RankAndFileUnitFactory.new.files(size).container_unit_count(size).other_units([1, 3] => ModelFactory.new.mm_length(20).mm_width(40).build).build }

      it "also counts the spaces taken up by the other units" do
        assert_equal size + 2, subject.occupied_spaces
      end
    end
  end
end

