require "spec_helper"
require "lone_model"
require "factories/lone_model_factory"
require "equipment/base"
require "attack"

describe LoneModel do
  describe "#attack_stats" do
    it "returns an attack stats object with the weapon skill and strength" do
      model = LoneModelFactory(stats: Stats.new(5, 3, 3, 1, 3, 1, 7, 7, 7))
      assert_equal AttackStats.new(5, 3), model.attack_stats(1)
    end

    it "caches the computation" do
      model = LoneModelFactory(stats: Stats.new(5, 3, 3, 1, 3, 1, 7, 7, 7))
      model.attack_stats(1)
      hash = { 1 => {[:strength] => 3, :attack_stats => AttackStats.new(5, 3)} }
      assert_equal hash, model.manipulations_store
    end
  end

  describe "#defend_stats" do
    it "returns a defend stats object with the weapon skill, toughness, armor save, and ward save" do
      model = LoneModelFactory(stats: Stats.new(5, 3, 3, 1, 3, 1, 7, 7, 6))
      assert_equal DefendStats.new(5, 3, 7, 6), model.defend_stats(1)
    end

    it "caches the computation" do
      model = LoneModelFactory(stats: Stats.new(5, 3, 3, 1, 3, 1, 7, 7, 6))
      model.defend_stats(1)
      hash = {
        1 => {
          [:toughness] => 3, [:armor_save] => 7, [:ward_save] => 6, :defend_stats => DefendStats.new(5, 3, 7, 6)
        }
      }
      assert_equal hash, model.manipulations_store
    end
  end

  describe "#dead?" do
    it "is true when wounds is 0 or less" do
      model = LoneModelFactory(stats: Stats.new(5, 3, 3, 0, 3, 1, 7, 7, 6))
      assert_equal true, model.dead?
    end

    it "is false otherwise" do
      model = LoneModelFactory(stats: Stats.new(5, 3, 3, 2, 3, 1, 7, 7, 6))
      assert_equal false, model.dead?
    end
  end

  describe "#destroy" do
    it "tells the model to take all of its wounds" do
      model = LoneModelFactory(stats: Stats.new(5, 3, 3, 2, 3, 1, 7, 7, 6))
      model.destroy
      assert_equal 0, model.wounds
    end
  end

  describe "#initiative_steps" do
    it "returns the model's initiative steps" do
      model = LoneModelFactory()
      assert_equal [3], model.initiative_steps(1)
    end

    it "calls the equipment for initiative steps" do
      item_a = Equipment::Base.new
      allow(item_a).to receive(:initiative_steps)
      model = LoneModelFactory(equipment: [item_a])
      model.initiative_steps(1)
      expect(item_a).to have_received(:initiative_steps).with(1, [3])
    end
  end

  describe "#take_wounds" do
    it "removes the given number of wounds from the model" do
      model = LoneModelFactory(stats: Stats.new(5, 3, 3, 4, 3, 1, 7, 7, 6))
      model.take_wounds(3)
      assert_equal 1, model.wounds
    end

    it "notifies the parent unit if the model is now dead and the model has a parent unit" do
      model = LoneModelFactory(stats: Stats.new(5, 3, 3, 4, 3, 1, 7, 7, 6))
      model.parent_unit = instance_spy("RankAndFileUnit")
      model.take_wounds(4)
      expect(model.parent_unit).to have_received(:other_unit_died).with(model)
    end

    it "clears the wound cache" do
      model = LoneModelFactory(stats: Stats.new(5, 3, 3, 4, 3, 1, 7, 7, 6))
      model.wounds
      model.take_wounds(3)
      assert_equal 1, model.wounds
    end
  end

  describe "#targets_in_interval" do
    it "iterates through the given intervals, return the key self, with a value of the number" \
       "of intervals that are within the range of this model"
  end

  describe "#matchups_for_initiative" do
    it "returns all the matchups from this model"
  end

  [[:weapon_skill, 2, 5],
   [:strength, 2, 7],
   [:toughness, 2, 5],
   [:initiative, 2, 6],
   [:armor_save, 2, 5],
   [:ward_save, 2, 4],
  ].each do |(stat_method, round_number, value)|
    describe "##{stat_method}" do
      it "returns the model's #{stat_method}" do
        stats = Stats.new(5, 3, 3, 4, 3, 1, 7, 7, 6)
        stats.send("#{stat_method}=", value)
        model = LoneModelFactory(stats: stats)
        assert_equal value, model.public_send(stat_method, 1)
      end

      it "calls each equipment" do
        item = Equipment::Base.new
        allow(item).to receive(stat_method)
        stats = Stats.new(5, 3, 3, 4, 3, 1, 7, 7, 6)
        stats.send("#{stat_method}=", value)
        model = LoneModelFactory(equipment: [item], stats: stats)
        model.public_send(stat_method, round_number)
        expect(item).to have_received(stat_method).with(round_number, value)
      end
    end
  end

  [[:wounds, 5],
   [:leadership, 4],
  ].each do |(stat_method, value)|
    describe "##{stat_method}" do
      it "returns the model's #{stat_method}" do
        stats = Stats.new(5, 3, 3, 4, 3, 1, 7, 7, 6)
        stats.send("#{stat_method}=", value)
        model = LoneModelFactory(stats: stats)
        assert_equal value, model.public_send(stat_method)
      end

      it "calls each equipment" do
        item = Equipment::Base.new
        allow(item).to receive(stat_method)
        stats = Stats.new(5, 3, 3, 4, 3, 1, 7, 7, 6)
        stats.send("#{stat_method}=", value)
        model = LoneModelFactory(equipment: [item], stats: stats)
        model.public_send(stat_method)
        expect(item).to have_received(stat_method).with(1, value)
      end
    end
  end

  describe "#make_attack" do
    it "creates an attack object" do
      model = LoneModelFactory()
      assert_equal Attack.new(1, 3, 3, []), model.make_attack(round_number: 1, number: 1)
    end
  end

  describe "#attacks" do
    it "returns the normal attack object" do
      model = LoneModelFactory()
      assert_equal [Attack.new(1, 3, 3, [])], model.attacks(1, model.initiative(1), 1)
    end

    it "doesn't return the normal attack when not the model's initiative" do
      model = LoneModelFactory()
      assert_equal [], model.attacks(1, 10, 1)
    end

    it "doesn't return the normal attack when the model has 0 attacks" do
      model = LoneModelFactory(stats: Stats.new(5, 3, 3, 4, 3, 0, 7, 7, 6))
      assert_equal [], model.attacks(1, 3, 1)
    end

    it "calls the equipment" do
      item = Equipment::Base.new
      allow(item).to receive(:pending_attacks)
      model = LoneModelFactory(equipment: [item], stats: Stats.new(5, 3, 3, 4, 3, 1, 7, 7, 6))
      model.attacks(1, 10, 1)
      expect(item).to have_received(:pending_attacks).with(1, [], 10)
    end
  end

  describe "#attack_count" do
    it "calls the normal counting process if in rank 1" do
      item = Equipment::Base.new
      attacks = 1
      allow(item).to receive(:attacks).and_return(attacks)
      model = LoneModelFactory(equipment: [item], stats: Stats.new(5, 3, 3, 4, 3, attacks, 7, 7, 6))
      assert_equal attacks, model.attack_count(1, 1)
      expect(item).to have_received(:attacks).with(1, attacks, model.parent_unit, 1)
    end

    it "is only 1 when rank 2" do
      model = LoneModelFactory(stats: Stats.new(5, 3, 3, 4, 3, 1, 7, 7, 6))
      assert_equal 1, model.attack_count(1, 2)
    end

    it "is only 1 when rank 3 only if the parent unit is a horde" do
      model = LoneModelFactory(stats: Stats.new(5, 3, 3, 4, 3, 1, 7, 7, 6))
      model.parent_unit = instance_spy("RankAndFileUnit", is_horde?: true)
      assert_equal 1, model.attack_count(1, 3)
    end

    it "is 0 otherwise" do
      model = LoneModelFactory(stats: Stats.new(5, 3, 3, 4, 3, 1, 7, 7, 6))
      assert_equal 0, model.attack_count(1, 4)
    end
  end

  describe "#hit_reroll_values" do
    it "calls the equipment to get hit reroll values" do
      item = Equipment::Base.new
      allow(item).to receive(:hit_reroll_values).and_return([1, 2, 3])
      model = LoneModelFactory(equipment: [item])
      model.hit_reroll_values(4)
      expect(item).to have_received(:hit_reroll_values).with(1, [], 4)
    end

    it "ensures the values are unique" do
      item = Equipment::Base.new
      allow(item).to receive(:hit_reroll_values).and_return([1, 1, 3])
      model = LoneModelFactory(equipment: [item])
      result = model.hit_reroll_values(4)
      assert_equal result.uniq, result
    end
  end

  describe "#wound_reroll_values" do
    it "calls the equipment to get wound reroll values" do
      item = Equipment::Base.new
      allow(item).to receive(:wound_reroll_values).and_return([1, 2, 3])
      model = LoneModelFactory(equipment: [item])
      model.wound_reroll_values(4)
      expect(item).to have_received(:wound_reroll_values).with(1, [], 4)
    end

    it "ensures the values are unique" do
      item = Equipment::Base.new
      allow(item).to receive(:wound_reroll_values).and_return([1, 1, 3])
      model = LoneModelFactory(equipment: [item])
      result = model.wound_reroll_values(4)
      assert_equal result.uniq, result
    end
  end
end
