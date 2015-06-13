require "lone_model"

class RankAndFileModel < LoneModel
  def take_wounds(wounds_caused)
    parent_unit.take_wounds(wounds_caused)
  end
end

