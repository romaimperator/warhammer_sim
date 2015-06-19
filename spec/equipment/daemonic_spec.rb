require "spec_helper"
require "equipment/daemonic"

module Equipment
  describe Daemonic do
    subject { Daemonic.new }

    describe "#taken_wounds" do
      it "records the number of wounds taken this round" do
        wounds = 4
        subject.taken_wounds(1, wounds)
        assert_equal wounds, subject.wounds_taken_this_round
      end
    end

    describe "#check_break_test" do
      it "restores wounds when the roll is 2" do
        unit = instance_spy("RankAndFileUnit")
        allow(unit).to receive(:leadership).and_return(8)
        wounds = 5
        subject.taken_wounds(1, wounds)
        break_test_roll = 2
        refute subject.check_break_test(1, false, break_test_roll, 0, unit)
        expect(unit).to have_received(:restore_wounds).with(wounds)
      end

      it "destroys the unit when the roll is 12" do
        unit = instance_spy("RankAndFileUnit")
        break_test_roll = 12
        allow(unit).to receive(:leadership).and_return(8)
        refute subject.check_break_test(1, false, break_test_roll, 0, unit)
        expect(unit).to have_received(:destroy)
      end

      [[6, 3, 1],
       [7, 3, 2],
       [10, 1, 3],
       [7, 20, 7],
       [3, 8, 3]].each do |break_test_roll, modifier, expected_wounds|
        it "takes additional wounds based on its leadership 8, the roll #{break_test_roll}, and the modifier #{modifier}" do
          unit = instance_spy("RankAndFileUnit")
          allow(unit).to receive(:leadership).and_return(8)
          refute subject.check_break_test(1, false, break_test_roll, modifier, unit)
          expect(unit).to have_received(:take_wounds).with(expected_wounds)
        end
      end
    end
  end
end

