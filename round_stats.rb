class RoundStats < Struct.new(:attacks, :wounds_caused)
  def wound_percentage
    wounds_caused.to_f / attacks
  end
end

