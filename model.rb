class Model < Struct.new(:name, :parts, :mm_width, :mm_length, :equipment)
  def method_missing(name, *args)
    parts[0].send(name, *args)
  end

  def dead?
    wounds <= 0
  end

  def strike_first?
    false
  end
end

