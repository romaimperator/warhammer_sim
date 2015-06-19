require "rank_list"
require "delegate"

class RankAndFileRankList < DelegateClass(RankList)
  def initialize(rank_list, rank_and_file_model)
    super(rank_list)
    @rank_and_file_model = rank_and_file_model
  end

  def each_model
    return to_enum(__callee__) unless block_given?

    processed_models = []
    each_position do |rank, file, unit|
      if unit == @rank_and_file_model
        yield [rank, file, unit]
      elsif !processed_models.include?(unit)
        processed_models << unit
        yield [rank, file, unit]
      else
        next
      end
    end
  end
end
