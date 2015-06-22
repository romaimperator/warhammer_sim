require "spec_helper"
require "attack"

class TestSubAttack < Attack
end

describe Attack do
  describe ".join" do
    it "joins two compatible attack objects" do
      attack = Attack.new(2, 3, 3, [])
      attack2 = Attack.new(3, 3, 3, [])
      assert_equal [Attack.new(5, 3, 3, [])], Attack.join([attack, attack2])
    end

    it "joins a two pairs of compatible objects which each pair is incompatible with each other" do
      attacks = [
        Attack.new(2, 3, 3, []),
        Attack.new(4, 1, 3, []),
        Attack.new(5, 1, 3, []),
        Attack.new(3, 3, 3, []),
      ]
      assert_equal [Attack.new(5, 3, 3, []), Attack.new(9, 1, 3, [])], Attack.join(attacks)
    end

    it "does not join any when they are all incompatible" do
      attacks = [
        Attack.new(2, 3, 3, []),
        Attack.new(4, 1, 3, []),
        Attack.new(5, 1, 4, []),
        Attack.new(3, 3, 3, [double(:item)]),
      ]
      assert_equal attacks, Attack.join(attacks)
    end
  end

  describe "#combine" do
    it "adds together the number of attacks when compatible" do
      attack = Attack.new(2, 3, 3, [])
      attack2 = Attack.new(3, 3, 3, [])
      assert_equal Attack.new(5, 3, 3, []), attack.combine(attack2)
    end

    it "adds together when the other attack is a subclass of Attack" do
      attack = Attack.new(2, 3, 3, [])
      attack2 = TestSubAttack.new(3, 3, 3, [])
      assert_equal Attack.new(5, 3, 3, []), attack.combine(attack2)
    end

    it "raises a TypeError if the weapon_skill is different" do
      attack = Attack.new(2, 3, 3, [])
      attack2 = Attack.new(3, 4, 3, [])
      assert_raises(TypeError) { attack.combine(attack2) }
    end

    it "raises a TypeError if the strength is different" do
      attack = Attack.new(2, 3, 3, [])
      attack2 = Attack.new(3, 3, 4, [])
      assert_raises(TypeError) { attack.combine(attack2) }
    end

    it "raises a TypeError if the equipment is different" do
      item = double(:item)
      attack = Attack.new(2, 3, 3, [item])
      attack2 = Attack.new(3, 3, 3, [])
      assert_raises(TypeError) { attack.combine(attack2) }
    end

    it "raises a TypeError if the other value isn't a kind of Attack" do
      attack = Attack.new(2, 3, 3, [])
      assert_raises(TypeError) { attack.combine(3) }
      assert_raises(TypeError) { attack.combine(nil) }
    end
  end
end

