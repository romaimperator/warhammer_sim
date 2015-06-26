require "spec_helper"
require "model"
require "factories/model_factory"
require "equipment"

class TestModel < Model
end

describe Model do
  it "sets the owner on each equipment to itself" do
    item = instance_spy("Equipment::Base")
    model = ModelFactory.new.equipment([item]).build
    expect(item).to have_received(:owner=).with(model)
  end

  describe "#hash" do
    it "is the value of the name's hash" do
      name = "halberd"
      assert_equal name.hash, ModelFactory.new.name(name).build.hash
    end
  end

  describe "#==" do
    it "is equal if the name matches" do
      assert_equal ModelFactory.new.build, ModelFactory.new.build
    end

    it "is true if the name matches even if the other is a subclass of model" do
      assert_equal ModelFactory.new.name("halberd").build, TestModel.new("halberd", 20, 20, [])
    end

    it "is false if the name doesn't match" do
      refute_equal ModelFactory.new.build, ModelFactory.new.name("other").build
    end

    it "is false if the other thing isn't a model" do
      refute_equal ModelFactory.new.build, 5
    end
  end

  describe "#<=>" do
    it "uses the name for comparing" do
      model_a = ModelFactory.new.name("aaaa").build
      model_b = ModelFactory.new.name("bbbb").build
      assert_equal -1, model_a <=> model_b
      assert_equal 1, model_b <=> model_a
    end

    it "is 0 when the names are the same" do
      model_a = ModelFactory.new.name("aaaa").build
      model_b = ModelFactory.new.name("aaaa").build
      assert_equal 0, model_a <=> model_b
    end
  end

  describe "#call_equipment" do
    it "calls the given method on each item" do
      item_a = Equipment::Base.new
      item_b = Equipment::Base.new
      allow(item_a).to receive(:roll_hits).and_return([1, 2, 3])
      allow(item_b).to receive(:roll_hits)
      model = ModelFactory.new.equipment([item_a, item_b]).build
      model.call_equipment(:roll_hits, 2, [1, 2, 3])
      expect(item_a).to have_received(:roll_hits).with(2, [1, 2, 3])
      expect(item_b).to have_received(:roll_hits).with(2, [1, 2, 3])
    end

    it "returns the final value from the accumulation" do
      item_a = Equipment::Base.new
      item_b = Equipment::Base.new
      allow(item_a).to receive(:roll_hits).and_return([2, 4, 6])
      allow(item_b).to receive(:roll_hits).and_return([3, 5, 7])
      model = ModelFactory.new.equipment([item_a, item_b]).build
      assert_equal [3, 5, 7], model.call_equipment(:roll_hits, 2, [1, 2, 3])
    end
  end

  describe "#call_equipment_hook" do
    it "calls the given method on each equipment" do
      item_a = Equipment::Base.new
      item_b = Equipment::Base.new
      allow(item_a).to receive(:before_combat)
      allow(item_b).to receive(:before_combat)
      model = ModelFactory.new.equipment([item_a, item_b]).build
      model.call_equipment_hook(:before_combat, 2, [1, 2, 3])
      expect(item_a).to have_received(:before_combat).with(2, [1, 2, 3])
      expect(item_b).to have_received(:before_combat).with(2, [1, 2, 3])
    end
  end

  describe "#remove_equipment" do
    it "removes the given equipment from the list" do
      item_a = Equipment::Base.new
      item_b = Equipment::Base.new
      model = ModelFactory.new.equipment([item_a, item_b]).build
      model.remove_equipment(item_a)
      assert_equal [item_b], model.equipment
    end
  end
end
