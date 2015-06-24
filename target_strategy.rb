
module TargetStrategy
  class Base
    def initialize(attacker, defender)
      @attacker = attacker
      @defender = defender
    end

    def pick(targets)
      fail NotYetImplemented
    end
  end

  class RandomTarget < Base
    def initialize
    end

    def pick(targets)
      targets.sample
    end
  end

  class RankAndFileFirst < Base
    def pick(targets)
      if targets.include?(@defender.rank_and_file)
        @defender.rank_and_file
      else
        RandomTarget.new.pick(targets)
      end
    end
  end

  class NonRankAndFileFirst < Base
    def pick(targets)
      targets -= [@defender.rank_and_file]
      if !targets.empty?
        RandomTarget.new.pick(targets)
      else
        @defender.rank_and_file
      end
    end
  end
end

