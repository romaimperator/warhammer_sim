require "spec_helper"
require "rank_and_file_model"

describe RankAndFileModel do
  describe "#take_wounds" do
    it "tells the parent unit to take its wounds" do
      model = RankAndFileModel.new(name, [], 20, 20, [])
      model.unit = spy
      model.take_wounds(5)
      expect(model.unit).to have_received(:take_wounds)
    end
  end
end

