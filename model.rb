class Model < Struct.new(:name, :parts, :mm_width, :mm_length, :equipment)
  def initialize(*args, &block)
    super
    parts.each { |part| part.model = self }
  end

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

