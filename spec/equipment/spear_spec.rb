require "spec_helper"
require "equipment/spear"

module Equipment
  describe FootSpear do
    subject { FootSpear.new }

    describe "#attacks" do
      it "allows the attacks through if rank 1 or 2" do
        unit = double(:unit, is_horde?: false)
        assert_equal 2, subject.attacks(1, 2, unit, 1)
        assert_equal 2, subject.attacks(1, 2, unit, 2)
      end

      it "allows the attacks if the rank is the one more than the last supporting attack rank" do
        unit = double(:unit, is_horde?: false)
        assert_equal 2, subject.attacks(1, 2, unit, 3)
      end

      it "allows rank 4 if the unit is a horde" do
        unit = double(:unit, is_horde?: true)
        assert_equal 2, subject.attacks(1, 2, unit, 4)
      end

      it "does not allow rank 4 if the unit is not a horde" do
        unit = double(:unit, is_horde?: false)
        assert_equal 0, subject.attacks(1, 2, unit, 4)
      end

      it "does not allow any rank beyond 4 even if a horde" do
        unit = double(:unit, is_horde?: true)
        assert_equal 0, subject.attacks(1, 2, unit, 5)
      end
    end
  end

  describe MountedSpear do
    subject { MountedSpear.new }

    describe MountedSpear do
      describe "#strength" do
        it "adds one to the strength if the first round" do
          assert_equal 4, subject.strength(1, 3)
        end

        it "does not if not the first round" do
          assert_equal 3, subject.strength(2, 3)
        end
      end
    end
  end
end

