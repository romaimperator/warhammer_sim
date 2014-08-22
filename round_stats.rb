class RoundStats < Struct.new(:attacks, :hits, :wounds_caused, :unsaved_wounds)
  def wound_percentage
    wounds_caused.to_f / attacks
  end
end

