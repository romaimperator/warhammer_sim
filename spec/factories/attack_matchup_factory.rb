require "factory"
require "attack_matchup"
require "attack"
require "factories/rank_and_file_model_factory"

def AttackMatchupFactory(round_number: 1, attack: Attack.new(1, 3, 3, []),
                         defender: RankAndFileModelFactory())
  AttackMatchup.new(round_number, attack, defender)
end

