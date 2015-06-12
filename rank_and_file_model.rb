require "model"

class RankAndFileModel < Model
  def take_wounds(wounds_caused)
    unit.take_wounds(wounds_caused)
  end
end

