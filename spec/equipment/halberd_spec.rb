require "spec_helper"
require "equipment/halberd"

module Equipment
  describe Halberd do
    subject { Halberd.new }

    describe "#strength" do
      it "adds one to the current strength" do
        assert_equal 4, subject.strength(3, 3)
      end
    end
  end
end

