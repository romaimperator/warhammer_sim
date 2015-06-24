require "spec_helper"
require "container_unit"

describe ContainerUnit do
  describe "#initialize" do
    it "sets parent_unit to self on all contained units" do
      a = instance_spy("RankAndFileUnit", dead?: true)
      b = instance_spy("RankAndFileUnit", dead?: true)
      c = instance_spy("RankAndFileUnit", dead?: true)
      unit = ContainerUnit.new([a, b, c])
      [a, b, c].each do |contained|
        expect(contained).to have_received(:parent_unit=).with(unit)
      end
    end
  end

  describe "#dead?" do
    it "returns true if all contained units are dead?" do
      a = instance_spy("RankAndFileUnit", dead?: true)
      b = instance_spy("RankAndFileUnit", dead?: true)
      c = instance_spy("RankAndFileUnit", dead?: true)
      unit = ContainerUnit.new([a, b, c])
      assert_equal true, unit.dead?
    end

    it "returns true if the container is empty" do
      assert_equal true, ContainerUnit.new([]).dead?
    end

    it "returns false if any contained unit is not dead?" do
      a = instance_spy("RankAndFileUnit", dead?: true)
      b = instance_spy("RankAndFileUnit", dead?: true)
      c = instance_spy("RankAndFileUnit", dead?: false)
      unit = ContainerUnit.new([a, b, c])
      assert_equal false, unit.dead?
    end
  end

  describe "#model_count" do
    it "returns the total number of models in all contained units" do
      a = instance_spy("RankAndFileUnit", model_count: 4)
      b = instance_spy("RankAndFileUnit", model_count: 2)
      c = instance_spy("RankAndFileUnit", model_count: 1)
      unit = ContainerUnit.new([a, b, c])
      assert_equal 7, unit.model_count
    end

    it "returns 0 when the container is empty" do
      assert_equal 0, ContainerUnit.new([]).model_count
    end
  end

  describe "#leadership" do
    it "returns the highest leadership in the unit" do
      a = instance_spy("RankAndFileUnit", leadership: 10)
      b = instance_spy("RankAndFileUnit", leadership: 8)
      c = instance_spy("RankAndFileUnit", leadership: 7)
      unit = ContainerUnit.new([a, b, c])
      assert_equal a.leadership, unit.leadership
    end
  end

  describe "#initiative_steps" do
    let(:a) { instance_spy("RankAndFileUnit", initiative_steps: [2, 6]) }
    let(:b) { instance_spy("RankAndFileUnit", initiative_steps: [2, 3]) }
    let(:c) { instance_spy("RankAndFileUnit", initiative_steps: [5]) }
    let(:unit) { ContainerUnit.new([a, b, c]) }

    it "returns a list of initiative values of all contained units" do
      result = unit.initiative_steps(1)
      assert_includes result, 2
      assert_includes result, 3
      assert_includes result, 5
      assert_includes result, 6
    end

    it "returns a unique list of values" do
      result = unit.initiative_steps(1)
      assert_equal result.uniq, result
    end

    it "returns an empty list when the container is empty" do
      assert_equal [], ContainerUnit.new([]).initiative_steps(1)
    end
  end
end
