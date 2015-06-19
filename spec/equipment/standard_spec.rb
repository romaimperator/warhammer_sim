require "spec_helper"
require "equipment/standard"

module Equipment
  describe Standard do
    subject { Standard.new }

    describe "#==" do
      it "is equal if the other is Standard" do
        assert subject == Standard.new
      end

      it "is not equal if the other is anything else" do
        refute subject == 3
      end
    end
  end
end

