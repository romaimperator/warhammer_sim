require "spec_helper"
require "factories/rank_and_file_model_factory"
require "rank_and_file_unit" # load to use verifying double

describe RankAndFileModel do
  describe "#take_wounds" do
    it "tells the parent unit to take its wounds" do
      model = RankAndFileModelFactory.new.build
      model.parent_unit = instance_spy("RankAndFileUnit")
      model.take_wounds(5)
      expect(model.parent_unit).to have_received(:take_wounds).with(5)
    end
  end
end

